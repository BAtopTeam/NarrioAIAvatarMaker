//
//  VideoGenerationInstance.swift
//  NarrioAIAvatarMaker
//
//  Created by b on 29.01.2026.
//

import SwiftUI
internal import Combine

@MainActor
final class VideoGenerationInstance: ObservableObject, Identifiable {
    let id = UUID()
    var createVideoState: CreateVideoState
    
    @Published var progress: Double = 0 {
        didSet {
            let newStep = step(for: progress)
            if newStep != currentStep {
                currentStep = newStep
            }
        }
    }
    @Published var currentStep: GenerationStep = .analyzing
    @Published var remainingSeconds = 180
    @Published var isComplete = false
    @Published var showRateApp = false
    @Published var errorMessage: String?
    @Published var videoURL: String?
    
    private var generationTask: Task<Void, Never>?
    private var progressTimer: Timer?
    private var pollingTimer: Timer?
    private weak var appState: AppState?
    
    init(state: CreateVideoState, appState: AppState) {
        self.createVideoState = state
        self.appState = appState
    }
    
    func startGeneration() {
        generationTask?.cancel()
        generationTask = Task { await generateVideo() }
        startProgressAnimation()
    }
    
    func generateVideo() async {
        guard let appState,
              let avatar = createVideoState.selectedAvatar,
              let voice = createVideoState.selectedVoice else {
            errorMessage = "Please select an avatar and voice"
            return
        }
        
        do {
            let taskId: String
            if avatar.isCustom, let data = avatar.localImageData {
                taskId = try await appState.createVideoFromImage(
                    imageData: data,
                    imageName: "avatar.jpg",
                    voice: voice,
                    script: createVideoState.script,
                    background: createVideoState.selectedBackground
                )
            } else {
                taskId = try await appState.createVideoFromPreset(
                    avatar: avatar,
                    voice: voice,
                    script: createVideoState.script,
                    background: createVideoState.selectedBackground
                )
            }
            
            startPolling(taskId: taskId)
            let savedTask = SavedTask(
                projectId: createVideoState.currentProjectId ?? UUID(),
                taskId: taskId
            )

            var savedTasks = LocalStorage.shared.load([SavedTask].self, key: "activeTasks") ?? []
            savedTasks.append(savedTask)
            LocalStorage.shared.save(savedTasks, key: "activeTasks")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func startPolling(taskId: String) {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { await self?.pollStatus(taskId: taskId) }
        }
    }
    
    func pollStatus(taskId: String) async {
        guard let appState else { return }
        do {
            let status = try await appState.pollTaskStatus(taskId: taskId)
            switch status.status {
            case .completed:
                pollingTimer?.invalidate()
                isComplete = true
                if !appState.showRatingView {
                    appState.tryShowRatingIfNeeded()
                }
                progress = 1.0
                let result = try await appState.fetchTaskResult(taskId: taskId)
                videoURL = result.video_url
                appState.updateProjectStatus(createVideoState.currentProjectId ?? UUID(), status: .ready, videoURL: videoURL, thumbnailURL: result.thumbnail_url, taskId: taskId, duration: result.duration)
            case .failed:
                if let projectId = createVideoState.currentProjectId {
                    appState.updateProjectStatus(projectId, status: .failed, videoURL: nil, thumbnailURL: nil, taskId: nil, duration: nil)
                }
                pollingTimer?.invalidate()
                errorMessage = status.error ?? "Failed"
            default: break
            }
        } catch {
            pollingTimer?.invalidate()
            errorMessage = error.localizedDescription
        }
    }
    
    private func startProgressAnimation() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            if isComplete || errorMessage != nil { timer.invalidate(); return }
            
            if progress < 0.95 {
                self.progress += max((0.95 - self.progress) * 0.03, 0.004)
                self.remainingSeconds = max(0, Int((1 - self.progress) * 180))
            }
        }
    }
    
    private func step(for progress: Double) -> GenerationStep {
        switch progress {
        case ..<0.15: return .analyzing
        case ..<0.35: return .preparingAvatar
        case ..<0.55: return .synthesizingVoice
        case ..<0.85: return .renderingVideo
        default: return .finalizing
        }
    }
    
    func retry() {
        cancel()

        progress = 0
        currentStep = .analyzing
        remainingSeconds = 180
        isComplete = false
        errorMessage = nil
        videoURL = nil

        startGeneration()
    }
    
    func cancel() {
        generationTask?.cancel()
        pollingTimer?.invalidate()
        progressTimer?.invalidate()
    }
    
    func reset() {
        cancel()
        progress = 0
        currentStep = .analyzing
        remainingSeconds = 180
        isComplete = false
        errorMessage = nil
        videoURL = nil
    }
}

