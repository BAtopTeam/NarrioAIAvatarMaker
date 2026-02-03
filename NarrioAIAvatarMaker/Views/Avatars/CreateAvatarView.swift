//
//  CreateAvatarView.swift
//  SynthesiaAI
//

import SwiftUI
import PhotosUI

struct CreateAvatarView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = CreateAvatarViewModel()
    @State var showPaywall = false
    @StateObject private var subManager = SubscriptionManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    title: viewModel.currentStep == .complete ? "Name" : "Create",
                    currentStep: viewModel.currentStep.rawValue,
                    totalSteps: 3,
                    onBack: {
                        viewModel.handleBack(dismiss: dismiss)
                    }
                )
                
                Group {
                    switch viewModel.currentStep {
                    case .gender:
                        genderSelectionView
                    case .photos:
                        photosUploadView
                    case .processing:
                        AvatarProcessingView(progress: viewModel.processingProgress)
                            .onAppear {
                                viewModel.startProcessing(appState: appState)
                            }
                    case .complete:
                        AvatarCompletionView(
                            createdAvatar: viewModel.createdAvatar,
                            selectedImageData: viewModel.selectedImageData,
                            avatarName: viewModel.avatarName,
                            creationMode: viewModel.creationMode,
                            onSave: { viewModel.showNameInput = true },
                            onCreateAnother: { viewModel.resetFlow() }
                        )
                    }
                }
                .animation(.easeInOut, value: viewModel.currentStep)
                
                Spacer()
                
                if viewModel.currentStep != .processing && viewModel.currentStep != .complete {
                    bottomButtons
                }
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView()
            }
            .preferredColorScheme(.light)
            .background(AppColors.cardBackground)
            .navigationBarHidden(true)
            .overlay(
                Group {
                    if viewModel.showNameInput {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                viewModel.showNameInput = false
                            }

                        VStack(spacing: 16) {
                            Text("Name your avatar")
                                .font(AppTypography.headline)
                                .foregroundColor(.black)

                            TextField("Avatar name", text: $viewModel.avatarName)
                                .padding()
                                .background(Color(.systemGray6))
                                .foregroundColor(.black)
                                .cornerRadius(8)

                            HStack(spacing: 16) {
                                Button(action: {
                                    viewModel.showNameInput = false
                                }) {
                                    Text("Cancel")
                                        .font(AppTypography.buttonMedium)
                                        .foregroundColor(AppColors.textSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(.systemGray5))
                                        .cornerRadius(AppRadius.medium)
                                }

                                Button(action: {
                                    viewModel.saveAvatar(appState: appState, dismiss: dismiss)
                                    viewModel.showNameInput = false
                                }) {
                                    Text("Save")
                                        .font(AppTypography.buttonMedium)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppColors.primary)
                                        .cornerRadius(AppRadius.medium)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .padding(.horizontal, 32)
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(1)
                    }
                }
            )
            .animation(.easeInOut, value: viewModel.showNameInput)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .onChange(of: viewModel.selectedPhotoItem) { newItem in
                Task {
                    await viewModel.handlePhotoSelection(newItem)
                }
            }
        }
    }
    
    // MARK: - Gender Selection View
    private var genderSelectionView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xxl) {
                VStack(spacing: AppSpacing.sm) {
                    Text("Select gender")
                        .font(AppTypography.title2)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("This helps personalize your avatar")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, AppSpacing.lg)
                
                ZStack(alignment: .bottom) {
                    HStack(spacing: AppSpacing.xxl) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            GenderOption(
                                gender: gender,
                                isSelected: viewModel.selectedGender == gender,
                                action: { viewModel.selectedGender = gender }
                            )
                        }
                    }
                    .padding(.top, AppSpacing.lg)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .background(AppColors.mainGradient)
    }
    
    // MARK: - Photos Upload / AI Prompt View
    private var photosUploadView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xxl) {
                if viewModel.creationMode == .photo {
                    photoUploadContent
                } else {
                    aiPromptContent
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            Spacer(minLength: 24)
        }
        .background(AppColors.mainGradient)
    }
    
    private var photoUploadContent: some View {
        VStack(spacing: AppSpacing.xxl) {
            VStack(spacing: AppSpacing.sm) {
                Text("Upload Photo")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Upload a clear front-facing photo")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, AppSpacing.lg)
            
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(AppColors.primary)
                    Text("Photo Guidelines")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Text("For best results, upload a clear front-facing photo with good lighting")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    GuidelineRow(text: "Face clearly visible and centered")
                    GuidelineRow(text: "Well-lit environment (natural light works best)")
                    GuidelineRow(text: "Plain background preferred")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
            
            if viewModel.selectedImageData == nil {
                PhotoUploadPlaceholder(selectedPhotoItem: $viewModel.selectedPhotoItem)
            } else if let imageData = viewModel.selectedImageData {
                SelectedPhotoPreview(
                    imageData: imageData,
                    selectedPhotoItem: $viewModel.selectedPhotoItem,
                    onRemove: { viewModel.removePhoto() }
                )
            }
        }
    }
    
    private var aiPromptContent: some View {
        VStack(spacing: AppSpacing.xxl) {
            VStack(spacing: AppSpacing.sm) {
                Text("Describe Your Avatar")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Our AI will generate a unique avatar based on your description")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, AppSpacing.lg)
            
            AIPromptInputView(
                aiPrompt: $viewModel.aiPrompt,
                promptSuggestions: viewModel.promptSuggestions
            )
        }
    }
    
    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        VStack(spacing: AppSpacing.md) {
            if viewModel.currentStep == .gender {
                PrimaryButton(title: "Next") {
                    viewModel.currentStep = .photos
                }
            } else if viewModel.currentStep == .photos {
                PrimaryButton(
                    title: "Create Avatar",
                    disabled: !viewModel.canProceedToProcessing
                ) {
                    if subManager.isSubscribed {
                        viewModel.startProcessing(appState: appState)
                    } else {
                        showPaywall = true
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xxl)
    }
}
