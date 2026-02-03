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
                CustomNavigationBar(
                    title: "Create Video",
                    currentStep: viewModel.currentStep.rawValue,
                    totalSteps: CreateVideoStep.allCases.count,
                    onBack: handleBack
                )
                
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
            .navigationBarHidden(true)
            .background(AppColors.background)
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

struct CustomNavigationBar: View {
    let title: String
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                }

                Spacer()

                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Color.clear
                    .frame(width: 24)
            }
            .frame(height: 44)

            StepIndicator(
                totalSteps: totalSteps,
                currentStep: currentStep
            )
        }
        .padding(.horizontal, AppSpacing.xxl)
        .padding(.vertical, 16)
        .background(.white)
        .overlay(
            Divider(),
            alignment: .bottom
        )
    }
}
