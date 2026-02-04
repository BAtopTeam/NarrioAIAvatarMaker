//
//  VoiceSelectionView.swift
//  SynthesiaAI
//

import SwiftUI
import AVFoundation

struct VoiceSelectionView: View {
    @ObservedObject var viewModel: CreateVideoViewModel
    @EnvironmentObject var appState: AppState
    @StateObject private var voiceVM = VoiceSelectionViewModel()
    @State private var showNoPreviewAlert = false
    @State private var alertMessage = ""

    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    headerSection
                    
                    SearchBar(text: $voiceVM.searchText, placeholder: "Search voices...")
                        .padding(.horizontal, AppSpacing.lg)
                    
                    voiceContent
                    
                    errorSection
                }
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, 120)
            }
            
            bottomButton
        }
        .onAppear {
            Task {
                await voiceVM.loadInitialData(appState: appState)
            }
        }
        .onDisappear {
            voiceVM.stopPlayback()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Image(systemName: "speaker.wave.2")
                .foregroundColor(AppColors.primary)
            Text("Select Voice")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            if appState.isLoadingVoices {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Button(action: {
                    Task {
                        await voiceVM.refreshVoices(appState: appState)
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Language Filter
    @ViewBuilder
    private var languageFilter: some View {
        let languages = voiceVM.availableLanguages(from: appState)
        if !languages.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    Chip(
                        title: "All",
                        isSelected: voiceVM.selectedLanguageFilter == nil,
                        action: { voiceVM.selectedLanguageFilter = nil }
                    )
                    
                    ForEach(languages.prefix(10), id: \.self) { language in
                        Chip(
                            title: language,
                            isSelected: voiceVM.selectedLanguageFilter == language,
                            action: { voiceVM.selectedLanguageFilter = language }
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }
    
    // MARK: - Voice Count
    private var voiceCount: some View {
        Text("\(voiceVM.filteredVoices(from: appState).count) voices available")
            .font(AppTypography.caption1)
            .foregroundColor(AppColors.textSecondary)
            .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Voice Content
    @ViewBuilder
    private var voiceContent: some View {
        let filteredVoices = voiceVM.filteredVoices(from: appState)
        
        if appState.isLoadingVoices && appState.allVoices.isEmpty {
            loadingView
        } else if filteredVoices.isEmpty {
            emptyView
        } else {
            voiceList(filteredVoices)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
            Text("Loading voices...")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxxl)
    }
    
    private var emptyView: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "speaker.slash")
                .font(.system(size: 40))
                .foregroundColor(AppColors.textTertiary)
            
            Text("No voices found")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Try adjusting your search or filters")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxxl)
    }
    
    private func voiceList(_ voices: [Voice]) -> some View {
        LazyVStack(spacing: 5) {
            ForEach(voices, id: \.id) { voice in
                voiceRowView(voice)
            }
        }
    }

    @ViewBuilder
    private func voiceRowView(_ voice: Voice) -> some View {
        let isSelected = viewModel.selectedVoice?.id == voice.id
        let isPlaying = voiceVM.currentlyPlayingVoiceId == voice.id

        VoiceRow(
            voice: voice,
            isSelected: isSelected,
            isPlaying: voiceVM.currentlyPlayingVoiceId == voice.id,
            action: { viewModel.selectedVoice = voice },
            onPlayToggle: {
                guard voice.hasPreview else {
                    alertMessage = "Preview not available for this voice."
                    showNoPreviewAlert = true
                    return
                }
                
                voiceVM.togglePlayback(for: voice)
                voiceVM.errorVoice = { error in
                    alertMessage = error
                    showNoPreviewAlert = true
                }
            }
        )
        .listRowSeparator(.visible)
        .alert(isPresented: $showNoPreviewAlert) {
            Alert(title: Text("No Preview"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Error Section
    @ViewBuilder
    private var errorSection: some View {
        if let error = appState.apiError {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.orange)
                Text(error)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(AppSpacing.md)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(AppRadius.medium)
            .padding(.horizontal, AppSpacing.lg)
        }
    }
    
    // MARK: - Bottom Button
    private var bottomButton: some View {
        VStack {
            PrimaryButton(
                title: viewModel.currentStep.nextButtonTitle,
                icon: "arrow.right",
                disabled: !viewModel.canProceed
            ) {
                viewModel.nextStep()
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
    }
}

// MARK: - Voice Row
struct VoiceRow: View {
    let voice: Voice
    let isSelected: Bool
    let isPlaying: Bool
    let action: () -> Void
    let onPlayToggle: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 44, height: 44)

                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
            }
            .onTapGesture {
                onPlayToggle()
            }
            .disabled(false)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(voice.normalName)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)

                    if voice.supportsEmotion {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.primary)
                    }
                }

                Text(voice.subtitle)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.textSecondary)

                if let languageCode = voice.languageCode {
                    Text(languageCode)
                        .font(AppTypography.caption2)
                        .foregroundColor(AppColors.textTertiary)
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(AppSpacing.md)
        .background(isSelected ? AppColors.primary.opacity(0.05) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}
