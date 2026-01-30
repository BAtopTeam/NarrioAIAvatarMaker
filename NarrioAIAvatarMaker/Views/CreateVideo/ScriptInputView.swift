//
//  ScriptInputView.swift
//  SynthesiaAI
//

import SwiftUI

struct ScriptInputView: View {
    @ObservedObject var viewModel: CreateVideoViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    scriptSection
                    
                    voiceToneSection
                    
                    languageSection
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, 120)
            }
            
            bottomButton
        }
    }
    
    // MARK: - Script Section
    private var scriptSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(AppColors.primary)
                Text("Your Script")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Text("Write or paste your video content")
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textSecondary)
            
            ZStack(alignment: .topLeading) {
                if viewModel.script.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start typing your script here...")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text("Example: Welcome! In this video, I'll show you how to create stunning AI-powered videos in just minutes using our platform.")
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(AppSpacing.md)
                }
                
                TextEditor(text: $viewModel.script)
                    .font(AppTypography.body)
                    .frame(minHeight: 150)
                    .padding(AppSpacing.sm)
                    .scrollContentBackground(.hidden)
            }
            .background(AppColors.background)
            .cornerRadius(AppRadius.medium)
            
            HStack(spacing: AppSpacing.lg) {
                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                    Text("\(viewModel.wordCount)")
                }
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textTertiary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text("~\(viewModel.estimatedDuration)")
                }
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
    }
    
    // MARK: - AI Improve Button
    private var aiImproveButton: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "sparkles")
                Text("AI Improve Script")
                Spacer()
                Image(systemName: "arrow.right")
            }
            .font(AppTypography.buttonMedium)
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, 14)
            .background(AppColors.primary)
            .cornerRadius(AppRadius.medium)
        }
    }
    
    // MARK: - Voice Tone Section
    private var voiceToneSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "speaker.wave.2")
                    .foregroundColor(AppColors.primary)
                Text("Voice Tone")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: AppSpacing.md) {
                ForEach(VoiceTone.allCases, id: \.self) { tone in
                    VoiceToneCard(
                        tone: tone,
                        isSelected: viewModel.voiceTone == tone,
                        action: { viewModel.voiceTone = tone }
                    )
                }
            }
        }
    }
    
    // MARK: - Language Section
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(AppColors.primary)
                Text("Language")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(spacing: 0) {
                ForEach(Language.languages) { language in
                    LanguageRow(
                        language: language,
                        isSelected: viewModel.selectedLanguage.id == language.id,
                        action: { viewModel.selectedLanguage = language }
                    )
                }
            }
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.medium)
        }
    }
    
    // MARK: - Bottom Button
    private var bottomButton: some View {
        VStack {
            PrimaryButton(
                title: viewModel.currentStep.nextButtonTitle,
                disabled: !viewModel.canProceed
            ) {
                viewModel.nextStep()
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
    }
}

// MARK: - Voice Tone Card
struct VoiceToneCard: View {
    let tone: VoiceTone
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(tone.icon)
                    .font(.title2)
                
                Text(tone.rawValue)
                    .font(AppTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(tone.description)
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.md)
            .background(isSelected ? AppColors.primary.opacity(0.1) : AppColors.cardBackground)
            .cornerRadius(AppRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primary)
                        .offset(x: 8, y: -8)
                }
            }
        }
    }
}

// MARK: - Language Row
struct LanguageRow: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Text(language.flag)
                    .font(.title2)
                
                Text(language.name)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(AppSpacing.md)
            .background(isSelected ? AppColors.primary.opacity(0.1) : Color.clear)
        }
    }
}
