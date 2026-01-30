//
//  VideoGenerationViewModel.swift
//  SynthesiaAI
//

import SwiftUI
internal import Combine
import AVKit

@MainActor
final class VideoGenerationViewModel: ObservableObject {

    // MARK: - Published
    @Published var progress: Double = 0 {
        didSet {
            let newStep = step(for: progress)
            if newStep != currentStep {
                print("➡️ STEP \(currentStep) → \(newStep) (progress=\(Int(progress * 100))%)")
                currentStep = newStep
            }
        }
    }
    
    @Published var currentStep: GenerationStep = .analyzing
    @Published var remainingSeconds = 180
    @Published var isComplete = false
    @Published var errorMessage: String?
    @Published var videoURL: String?

    // MARK: - Private
    @Published var isCancelled = false

    private var generationTask: Task<Void, Never>?
    private var progressTimer: Timer?
    private var pollingTimer: Timer?
    private weak var appState: AppState?
    @Published var createVideoState = CreateVideoState()

    // MARK: - Configuration
    func configure(appState: AppState, state: CreateVideoState) {
           self.appState = appState
           self.createVideoState = state
       }

    // MARK: - Start
    func startGeneration() {
        isCancelled = false

        generationTask?.cancel()
        generationTask = Task {
            if let taskId = createVideoState.currentTaskId {
                startPolling(taskId: taskId)
            } else {
                await generateVideo()
            }
        }
    }

    // MARK: - Generate Video
    func generateVideo() async {
        guard let appState,
              let avatar = createVideoState.selectedAvatar,
              let voice = createVideoState.selectedVoice else {
            errorMessage = "Please select an avatar and voice"
            return
        }

        startProgressAnimation()

        do {
            let taskId: String

            if avatar.isCustom, let imageData = avatar.localImageData {
                taskId = try await appState.createVideoFromImage(
                    imageData: imageData,
                    imageName: "avatar.jpg",
                    voice: voice,
                    script: createVideoState.script,
                    background: createVideoState.selectedBackground
                )
            } else if avatar.heygenAvatarId != nil {
                taskId = try await appState.createVideoFromPreset(
                    avatar: avatar,
                    voice: voice,
                    script: createVideoState.script,
                    background: createVideoState.selectedBackground
                )
            } else {
                throw APIError.serverError("Avatar is not compatible")
            }

            createVideoState.currentTaskId = taskId

            startPolling(taskId: taskId)

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Polling
    func startPolling(taskId: String) {
        pollingTimer?.invalidate()

        pollingTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { await self?.pollTaskStatus(taskId: taskId) }
        }
    }

    func pollTaskStatus(taskId: String) async {
        guard let appState, !isCancelled else { return }

        do {
            let status = try await appState.pollTaskStatus(taskId: taskId)

            switch status.status {

            case .pending, .processing:
                break

            case .completed:
                pollingTimer?.invalidate()
                progress = 1.0
                isComplete = true
                currentStep = .finalizing

                Task {
                    do {
                        let result = try await appState.fetchTaskResult(taskId: taskId)

                        videoURL = result.video_url

                        let project = appState.createProject(
                            from: createVideoState,
                            taskId: taskId,
                            videoResult: result
                        )

                        createVideoState.currentProjectId = project.id

                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }

            case .failed:
                pollingTimer?.invalidate()
                errorMessage = status.error ?? "Video generation failed"

            case .unknown:
                break
            }

        } catch {
            pollingTimer?.invalidate()
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Progress Animation
    func startProgressAnimation() {
        progressTimer?.invalidate()

        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] timer in
            guard let self, !self.isCancelled else {
                timer.invalidate()
                return
            }

            if self.isComplete || self.errorMessage != nil {
                timer.invalidate()
                return
            }

            if self.progress < 0.95 {
                self.progress += max((0.95 - self.progress) * 0.03, 0.004)
                self.remainingSeconds = max(0, Int((1 - self.progress) * 180))
            }
        }
    }

    // MARK: - Step mapping
    private func step(for progress: Double) -> GenerationStep {
        switch progress {
        case ..<0.15: return .analyzing
        case ..<0.35: return .preparingAvatar
        case ..<0.55: return .synthesizingVoice
        case ..<0.85: return .renderingVideo
        default: return .finalizing
        }
    }

    // MARK: - Retry / Cleanup
    func retry() {
        errorMessage = nil
        progress = 0
        currentStep = .analyzing
        startGeneration()
    }

    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    deinit {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    func cancelGeneration() {
        isCancelled = true

        generationTask?.cancel()
        generationTask = nil

        stopPolling()

        progressTimer?.invalidate()
        progressTimer = nil

        reset()
    }
    
    func reset() {
        progress = 0
        currentStep = .analyzing
        remainingSeconds = 180
        isComplete = false
        errorMessage = nil
        videoURL = nil
        stopPolling()
        createVideoState.currentTaskId = nil
    }
}

@MainActor
final class VideoGenerationManager: ObservableObject {
    @Published var activeGenerations: [VideoGenerationInstance] = []
    
    func startNewGeneration(state: CreateVideoState, appState: AppState) -> VideoGenerationInstance {
        let instance = VideoGenerationInstance(state: state, appState: appState)
        activeGenerations.append(instance)
        
        instance.startGeneration()
        return instance
    }
    
    func remove(_ instance: VideoGenerationInstance) {
        instance.cancel()
        activeGenerations.removeAll { $0.id == instance.id }
    }
}

