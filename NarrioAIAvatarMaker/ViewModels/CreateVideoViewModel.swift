//
//  CreateVideoViewModel.swift
//  SynthesiaAI
//

import SwiftUI
internal import Combine

@MainActor
class CreateVideoViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var script = ""
    @Published var voiceTone: VoiceTone = .professional
    @Published var selectedLanguage = Language.languages[0]
    @Published var selectedAvatar: Avatar?
    @Published var selectedVoice: Voice?
    @Published var selectedBackground: Background?
    @Published var currentStep: CreateVideoStep = .script
    @Published var showGenerating = false
    
    // MARK: - Filters
    @Published var avatarGenderFilter: Gender?
    @Published var avatarStyleFilter: AvatarStyle = .all
    
    // MARK: - API Integration
    @Published var currentTaskId: String?
    @Published var currentProjectId: UUID?
    @Published var isGenerating = false
    @Published var generationError: String?
    
    // MARK: - Computed Properties
    var estimatedDuration: String {
        let wordCount = script.split(separator: " ").count
        let seconds = Double(wordCount) / 2.5
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    var estimatedDurationSeconds: TimeInterval {
        let wordCount = script.split(separator: " ").count
        return Double(wordCount) / 2.5
    }
    
    var wordCount: Int {
        script.split(separator: " ").count
    }
    
    var canProceed: Bool {
        switch currentStep {
        case .script:
            return !script.isEmpty
        case .avatar:
            return selectedAvatar != nil
        case .voice:
            return selectedVoice != nil
        case .background:
            return selectedBackground != nil
        case .preview:
            return true
        }
    }
    
    func toCreateVideoState() -> CreateVideoState {
        return CreateVideoState(
            script: script,
            voiceTone: voiceTone,
            language: selectedLanguage,
            selectedAvatar: selectedAvatar,
            selectedVoice: selectedVoice,
            selectedBackground: selectedBackground,
            currentStep: currentStep,
            currentTaskId: currentTaskId,
            currentProjectId: UUID()
        )
    }
    
    // MARK: - Navigation
    func nextStep() {
        guard let nextStep = CreateVideoStep(rawValue: currentStep.rawValue + 1) else {
            return
        }
        withAnimation {
            currentStep = nextStep
        }
    }
    
    func previousStep() {
        guard let prevStep = CreateVideoStep(rawValue: currentStep.rawValue - 1) else {
            return
        }
        withAnimation {
            currentStep = prevStep
        }
    }
    
    func goToStep(_ step: CreateVideoStep) {
        withAnimation {
            currentStep = step
        }
    }
    
    func generateVideo() {
        showGenerating = true
    }
    
    // MARK: - Reset
    func reset() {
        script = ""
        voiceTone = .professional
        selectedLanguage = Language.languages[0]
        selectedAvatar = nil
        selectedVoice = nil
        selectedBackground = nil
        currentStep = .script
        showGenerating = false
        currentTaskId = nil
        currentProjectId = nil
        isGenerating = false
        generationError = nil
        avatarGenderFilter = nil
        avatarStyleFilter = .all
    }
}

@MainActor
final class CreateVideoFlow: ObservableObject {
    @Published var isPresented = false
    @Published var viewModel = CreateVideoViewModel()

    func open(
        avatar: Avatar? = nil,
        template: VideoTemplate? = nil,
        startStep: CreateVideoStep = .script
    ) {
        viewModel.reset()

        if let template {
            viewModel.script = template.script
            viewModel.selectedAvatar = template.avatar
            viewModel.selectedVoice = template.voice
            viewModel.selectedBackground = template.background
        }

        if let avatar {
            viewModel.selectedAvatar = avatar
        }

        viewModel.currentStep = startStep
        isPresented = true
    }

    func close() {
        viewModel.reset()
        isPresented = false
    }
}
