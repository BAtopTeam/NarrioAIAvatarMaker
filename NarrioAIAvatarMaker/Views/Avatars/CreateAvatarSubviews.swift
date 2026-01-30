//
//  CreateAvatarSubviews.swift
//  SynthesiaAI
//

import SwiftUI
import PhotosUI

// MARK: - Gender Option
struct GenderOption: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(gender == .male ? .man : .women)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 171, height: 300)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.large)
                            .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 4)
                    )
                    .cornerRadius(AppRadius.large)

                VStack {
                    Spacer()

                    HStack(spacing: 8) {
                        Circle()
                            .stroke(
                                isSelected ? AppColors.primary : AppColors.textTertiary,
                                lineWidth: 2
                            )
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .fill(isSelected ? AppColors.primary : Color.clear)
                                    .frame(width: 12, height: 12)
                            )

                        Text(gender == .male ? "Man" : "Woman")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppRadius.full)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.full)
                            .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
                    )
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)
                }
            }
            .frame(width: 171, height: 300)
        }
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Creation Mode Button
struct CreationModeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : AppColors.primary)
                
                Text(title)
                    .font(AppTypography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.lg)
            .background(isSelected ? AppColors.primary : AppColors.background)
            .cornerRadius(AppRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .stroke(isSelected ? AppColors.primary : AppColors.primary.opacity(0.3), lineWidth: 2)
            )
        }
    }
}

// MARK: - Guideline Row
struct GuidelineRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.success)
            
            Text(text)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Photo Thumbnail
struct PhotoThumbnail: View {
    let index: Int
    var hasWarning: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.small)
                .fill(LinearGradient(
                    colors: [AppColors.primary.opacity(0.3), AppColors.accent.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .aspectRatio(1, contentMode: .fit)
            
            VStack {
                HStack {
                    Spacer()
                    if hasWarning {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.orange)
                            .padding(4)
                    } else if index % 3 == 0 {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                            .padding(4)
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - Next Step Row
struct NextStepRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.success)
            
            Text(text)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Photo Upload Placeholder
struct PhotoUploadPlaceholder: View {
    @Binding var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
            VStack(spacing: AppSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.primary)
                }
                
                VStack(spacing: 4) {
                    Text("Upload Your Photo")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Tap to choose from your photo library")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text("Choose Photo")
                    .font(AppTypography.buttonMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.primary)
                    .cornerRadius(AppRadius.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.xxxl)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large)
                    .stroke(AppColors.primary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
            )
        }
    }
}

// MARK: - Selected Photo Preview
struct SelectedPhotoPreview: View {
    let imageData: Data
    @Binding var selectedPhotoItem: PhotosPickerItem?
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.large))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.large)
                            .stroke(AppColors.primary, lineWidth: 3)
                    )
            }
            
            HStack(spacing: AppSpacing.md) {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Text("Change Photo")
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(AppRadius.medium)
                }
                
                Button(action: onRemove) {
                    Text("Remove")
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(AppRadius.medium)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
    }
}

// MARK: - AI Prompt Input View
struct AIPromptInputView: View {
    @Binding var aiPrompt: String
    let promptSuggestions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppColors.primary)
                    Text("AI Prompt")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                ZStack(alignment: .topLeading) {
                    if aiPrompt.isEmpty {
                        Text("Describe the avatar you want to create...\n\nExample: Portrait of a young professional woman with blonde hair, wearing a blue blazer, warm smile, studio lighting, professional headshot")
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.textTertiary)
                            .padding(AppSpacing.md)
                    }
                    
                    TextEditor(text: $aiPrompt)
                        .font(AppTypography.body)
                        .frame(minHeight: 150)
                        .padding(AppSpacing.sm)
                        .scrollContentBackground(.hidden)
                }
                .background(AppColors.background)
                .cornerRadius(AppRadius.medium)
            }
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
            
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Quick Suggestions")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(promptSuggestions, id: \.self) { suggestion in
                            Button(action: { aiPrompt = suggestion }) {
                                Text(suggestion)
                                    .font(AppTypography.caption1)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(AppRadius.medium)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Processing View
struct AvatarProcessingView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 4)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(AppColors.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: progress)
                
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary)
            }
            
            VStack(spacing: AppSpacing.sm) {
                Text("Processing Your Avatar")
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Our AI is creating your custom avatar...")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Completion View
struct AvatarCompletionView: View {
    let createdAvatar: Avatar?
    let selectedImageData: Data?
    let avatarName: String
    let creationMode: AvatarCreationMode
    let onSave: () -> Void
    let onCreateAnother: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xxl) {
                successIcon

                successMessage

                avatarPreview

                whatsNextSection

                actionButtons
            }
            .padding(.vertical, AppSpacing.lg)
            .padding(.horizontal, AppSpacing.lg)
        }
    }

    private var successIcon: some View {
        ZStack {
            Circle()
                .fill(AppColors.primary)
                .frame(width: 80, height: 80)

            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }

    private var successMessage: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Avatar Created!")
                .font(AppTypography.title2)
                .foregroundColor(AppColors.textPrimary)

            Text("Your custom avatar is ready to use")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var avatarPreview: some View {
        VStack(spacing: AppSpacing.md) {
            if let avatar = createdAvatar, let imageData = avatar.localImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.primary, lineWidth: 3))
            } else if let imageData = selectedImageData,
                      let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.primary, lineWidth: 3))
            } else {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(avatarName.isEmpty ? "AV" : String(avatarName.prefix(2)).uppercased())
                            .font(.title.bold())
                            .foregroundColor(AppColors.primary)
                    )
            }

            VStack(spacing: 4) {
                Text(createdAvatar?.name ?? (avatarName.isEmpty ? "Custom Avatar" : avatarName))
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)

                Text(creationMode == .aiPrompt ? "AI Generated" : "Photo Avatar")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(AppSpacing.xxl)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
        .frame(maxWidth: .infinity)
    }

    private var whatsNextSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("What's Next?")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                NextStepRow(text: "Use this avatar in your video projects")
                NextStepRow(text: "Create more custom avatars anytime")
                NextStepRow(text: "Switch between avatars in the Create flow")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButtons: some View {
        VStack(spacing: AppSpacing.md) {
            PrimaryButton(title: "Save") { onSave() }

            SecondaryButton(title: "Create Another Avatar") { onCreateAnother() }
        }
        .padding(.bottom, AppSpacing.xxl)
    }
}
