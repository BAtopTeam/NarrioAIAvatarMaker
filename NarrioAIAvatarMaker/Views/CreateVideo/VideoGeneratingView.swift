//
//  VideoGeneratingView.swift
//  SynthesiaAI
//

import SwiftUI

struct VideoGeneratingView: View {
    @ObservedObject var instance: VideoGenerationInstance
    @ObservedObject var viewModel: CreateVideoViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var createVideoFlow: CreateVideoFlow

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xxl) {
                Spacer()
                
                if let error = instance.errorMessage {
                    errorView(error: error)
                } else if instance.isComplete {
                    completionView
                } else {
                    processingView
                }
                
                Spacer()
            }
            .background(AppColors.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        appState.selectedTab = .home
                        viewModel.reset()
                        createVideoFlow.close()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
    }
    
    // MARK: - Processing View
    private var processingView: some View {
        VStack(spacing: AppSpacing.xxl) {
            VStack(spacing: AppSpacing.sm) {
                Text("Generating Your Video")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("This usually takes 2-3 minutes")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            progressBar
            
            stepsView
            
            tipView
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: AppSpacing.md) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.primary.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.progressGradient)
                        .frame(width: geometry.size.width * instance.progress, height: 8)
                        .animation(.easeInOut, value: instance.progress)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(Int(instance.progress * 100))%")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.primary)
                
                Spacer()
                
                if instance.remainingSeconds > 0 {
                    Text("~\(instance.remainingSeconds)s remaining")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textSecondary)
                } else {
                    Text("Almost done...")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.xxxl)
    }
    
    private var stepsView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            ForEach(GenerationStep.allCases, id: \.self) { step in
                GenerationStepRow(
                    step: step,
                    isActive: instance.currentStep == step,
                    isComplete: step.rawValue < instance.currentStep.rawValue
                )
            }
        }
        .padding(AppSpacing.xxl)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    private var tipView: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            
            Text("You can close this screen. We'll notify you when your video is ready.")
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.lg)
        .background(AppColors.primary.opacity(0.05))
        .cornerRadius(AppRadius.medium)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: AppSpacing.xxl) {
            ZStack {
                Circle()
                    .fill(AppColors.success)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: AppSpacing.sm) {
                Text("Video Ready!")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Your video has been generated successfully")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(spacing: AppSpacing.md) {
                PrimaryButton(title: "View Video") {
                    appState.selectedTab = .projects
                    viewModel.reset()
                    instance.reset()
                    createVideoFlow.close()
                    dismiss()
                }
                
                SecondaryButton(title: "Create Another") {
                    viewModel.reset()
                    instance.reset()
                    createVideoFlow.close()
                    dismiss()
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
    
    // MARK: - Error View
    private func errorView(error: String) -> some View {
        VStack(spacing: AppSpacing.xxl) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: AppSpacing.sm) {
                Text("Generation Failed")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(error)
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: AppSpacing.md) {
                PrimaryButton(title: "Try Again") {
                    instance.retry()
                }
                
                SecondaryButton(title: "Go Back") {
                    instance.reset()
                    createVideoFlow.close()
                    dismiss()
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
}

// MARK: - Generation Step Row
struct GenerationStepRow: View {
    let step: GenerationStep
    let isActive: Bool
    let isComplete: Bool
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(isComplete ? AppColors.success : (isActive ? AppColors.primary : AppColors.textTertiary.opacity(0.3)))
                    .frame(width: 28, height: 28)
                
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(step.stepNumber)")
                        .font(AppTypography.caption1)
                        .fontWeight(.bold)
                        .foregroundColor(isActive ? .white : AppColors.textSecondary)
                }
            }
            
            Text(step.title)
                .font(isActive ? AppTypography.headline : AppTypography.body)
                .foregroundColor(isComplete ? AppColors.textSecondary : (isActive ? AppColors.primary : AppColors.textSecondary))
            
            Spacer()
            
            if isActive {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                    .scaleEffect(0.8)
            }
        }
    }
}

struct VideoGenerationOverlay: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var videoGenerationVM: VideoGenerationViewModel
    
    @State private var showOverlay: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            if appState.isCreatingVideo || videoGenerationVM.progress > 0 {
                miniOverlay
                    .padding(.horizontal, 16)
                    .padding(.bottom, 48)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: appState.isCreatingVideo || videoGenerationVM.progress > 0)
            }
        }
        .onChange(of: videoGenerationVM.progress) { _ in
            showOverlay = true
        }
    }
    
    private var miniOverlay: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(circleColor)
                    .frame(width: 40, height: 40)
                
                if videoGenerationVM.isComplete {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.headline)
                } else if videoGenerationVM.errorMessage != nil {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                        .font(.headline)
                } else {
                    ProgressView(value: videoGenerationVM.progress)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.6)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                
                if !videoGenerationVM.isComplete, let remaining = videoGenerationVM.remainingSeconds as Int? {
                    Text("~\(remaining)s remaining")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            Button(action: {
                appState.isShowingVideoGeneration = true
            }) {
                Text("View")
                    .font(.caption.bold())
                    .foregroundColor(AppColors.primary)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(LinearGradient(colors: [AppColors.primary.opacity(0.9), AppColors.primary.opacity(0.8)],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
    }
    
    // MARK: - Helpers
    private var circleColor: Color {
        if videoGenerationVM.isComplete {
            return AppColors.success
        } else if videoGenerationVM.errorMessage != nil {
            return .red
        } else {
            return AppColors.primary
        }
    }
    
    private var statusTitle: String {
        if let error = videoGenerationVM.errorMessage {
            return "Error"
        } else if videoGenerationVM.isComplete {
            return "Video Ready"
        } else {
            return "Generating Video"
        }
    }
}

// MARK: - UIKit Blur Support
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
