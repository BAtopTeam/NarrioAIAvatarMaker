//
//  CreateVideoView.swift
//  SynthesiaAI
//

import SwiftUI
internal import Combine
import AVKit

struct CreateVideoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: CreateVideoViewModel
    @EnvironmentObject var videoGenerationVM: VideoGenerationViewModel
    @EnvironmentObject var createVideoFlow: CreateVideoFlow
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                StepIndicator(
                    totalSteps: CreateVideoStep.allCases.count,
                    currentStep: viewModel.currentStep.rawValue
                )
                .padding(.horizontal, AppSpacing.xxl)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
                
                Group {
                    switch viewModel.currentStep {
                    case .script:
                        ScriptInputView(viewModel: viewModel)
                    case .avatar:
                        AvatarSelectionView(viewModel: viewModel)
                    case .voice:
                        VoiceSelectionView(viewModel: viewModel)
                    case .background:
                        BackgroundSelectionView(viewModel: viewModel)
                    case .preview:
                        PreviewView(viewModel: viewModel)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
            .background(AppColors.background)
            .navigationTitle("Create Video")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: handleBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
    }
    
    private func handleBack() {
        if viewModel.currentStep == .script {
            viewModel.reset()
            createVideoFlow.close()
        } else {
            withAnimation {
                viewModel.previousStep()
            }
        }
    }
}
