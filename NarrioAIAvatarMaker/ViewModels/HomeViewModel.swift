//
//  HomeViewModel.swift
//  SynthesiaAI
//

import SwiftUI
internal import Combine

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showCreateVideo = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var createVideoVM = CreateVideoViewModel()

    // MARK: - Actions
    func openCreateVideo() {
        showCreateVideo = true
    }

    func closeCreateVideo() {
        showCreateVideo = false
    }

    func openCreateVideo(with template: VideoTemplate) {
        createVideoVM.script = template.script
        createVideoVM.selectedAvatar = template.avatar
        createVideoVM.selectedVoice = template.voice
        createVideoVM.selectedBackground = template.background
        createVideoVM.currentStep = .preview
        showCreateVideo = true
    }
    
    func openCreateVideoOnAvatarStage(with template: VideoTemplate) {
        createVideoVM.script = template.script
        createVideoVM.selectedAvatar = template.avatar
        createVideoVM.selectedVoice = template.voice
        createVideoVM.selectedBackground = template.background
        createVideoVM.currentStep = .preview
        showCreateVideo = true
    }

    func navigateToProjects(appState: AppState) {
        appState.selectedTab = .projects
    }

    // MARK: - Data Loading
    func loadInitialData(appState: AppState) async {
        isLoading = true
        await appState.loadInitialData()
        isLoading = false
    }

    func refreshData(appState: AppState) async {
        isLoading = true
        await appState.loadInitialData()
        isLoading = false
    }
}

