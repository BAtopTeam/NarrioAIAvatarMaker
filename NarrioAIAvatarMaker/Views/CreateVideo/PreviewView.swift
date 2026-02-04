//
//  PreviewView.swift
//  SynthesiaAI
//

import SwiftUI

enum GenerationPermission {
    case allowed
    case showPaywall
}

struct PreviewView: View {
    @ObservedObject var viewModel: CreateVideoViewModel
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var videoGenerationVM: VideoGenerationViewModel
    @State var showPaywall = false
    @StateObject private var subManager = SubscriptionManager.shared
    @State var currentGeneration: VideoGenerationInstance? = nil
    @EnvironmentObject var videoGenerationManager: VideoGenerationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    videoPreview
                    
                    statsRow
                    
                    summarySection
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, 120)
            }
            
            VStack {
                PrimaryButton(
                    title: "Generate Video",
                    icon: "play.fill"
                ) {
                    let permission = subManager.generationPermission(
                        generationsCount: appState.generationsCount,
                        isSubscribed: subManager.isSubscribed,
                        plan: subManager.currentSubscriptionType()
                    )

                    switch permission {
                    case .allowed:
                        let stateCopy = viewModel.toCreateVideoState()

                        let instance = videoGenerationManager.startNewGeneration(
                            state: stateCopy,
                            appState: appState
                        )

                        _ = appState.createProject(
                            from: stateCopy,
                            taskId: nil,
                            videoResult: nil
                        )

                        currentGeneration = instance
                    case .showPaywall:
                        showPaywall = true
                    }
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
        }
        .fullScreenCover(item: $currentGeneration) { instance in
            VideoGeneratingView(instance: instance, viewModel: viewModel)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
    
    // MARK: - Video Preview
    private var videoPreview: some View {
        ZStack {
            if let background = viewModel.selectedBackground {
                if background.type == .gradient {
                    LinearGradient(
                        colors: background.colors ?? [],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else if background.type == .image {
                    Image(background.imageName ?? "")
                        .resizable()
                        .scaledToFill()
                } else {
                    background.colors?.first ?? Color.white
                }
            } else {
                AppColors.primary.opacity(0.2)
            }
            
            if let avatar = viewModel.selectedAvatar {
                VStack {
                    avatarImage(for: avatar)
                }
            } else {
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(height: 200)
        .cornerRadius(AppRadius.large)
    }
    
    @ViewBuilder
    private func avatarImage(for avatar: Avatar) -> some View {
        if let imageData = avatar.localImageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
        } else if !avatar.imageURL.isEmpty, let url = URL(string: avatar.imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 100, height: 100)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
                case .failure:
                    avatarPlaceholder(for: avatar)
                @unknown default:
                    avatarPlaceholder(for: avatar)
                }
            }
        } else {
            avatarPlaceholder(for: avatar)
        }
    }
    
    private func avatarPlaceholder(for avatar: Avatar) -> some View {
        Circle()
            .fill(Color.white.opacity(0.3))
            .frame(width: 100, height: 100)
            .overlay(
                Text(String(avatar.name.prefix(2)).uppercased())
                    .font(.title.bold())
                    .foregroundColor(.white)
            )
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 3)
            )
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack {
            VStack(spacing: 4) {
                Text("Estimated Duration")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.textSecondary)
                Text(viewModel.estimatedDuration)
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.primary)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Generation Time")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.textSecondary)
                Text("~2-3 minutes")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
    }
    
    // MARK: - Summary Section
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Summary")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                SummaryRow(
                    icon: "doc.text",
                    imageData: nil,
                    title: "Script",
                    value: String(viewModel.script.prefix(50)) + (viewModel.script.count > 50 ? "..." : ""),
                    showEdit: true
                ) {
                    viewModel.goToStep(.script)
                }
                
                Divider().padding(.leading, 50)
                
                SummaryRow(
                    icon: "person.crop.circle",
                    imageData: viewModel.selectedAvatar?.localImageData,
                    title: "Avatar",
                    value: viewModel.selectedAvatar?.name ?? "Not selected",
                    subtitle: viewModel.selectedAvatar?.style.rawValue,
                    showEdit: true
                ) {
                    viewModel.goToStep(.avatar)
                }
                
                Divider().padding(.leading, 50)
                
                SummaryRow(
                    icon: "speaker.wave.2",
                    imageData: nil,
                    title: "Voice",
                    value: viewModel.selectedVoice?.normalName ?? "Not selected",
                    subtitle: viewModel.selectedVoice?.subtitle,
                    showEdit: true
                ) {
                    viewModel.goToStep(.voice)
                }
                
                Divider().padding(.leading, 50)
                
                SummaryRow(
                    icon: "paintpalette",
                    imageData: nil,
                    title: "Style",
                    value: viewModel.selectedBackground?.name ?? "Not selected",
                    subtitle: viewModel.selectedBackground?.type.rawValue.lowercased(),
                    showEdit: true
                ) {
                    viewModel.goToStep(.background)
                }
            }
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
        }
    }
}

// MARK: - Summary Row
struct SummaryRow: View {
    let icon: String
    let imageData: Data?
    let title: String
    let value: String
    var subtitle: String? = nil
    var showEdit: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.textSecondary)
                
                HStack(spacing: 4) {
                    if title == "Avatar", let firstChar = value.first {
                        if let imageData = imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 24)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.small))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(value)
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(AppTypography.caption2)
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                }
            }
            
            Spacer()
            
            if showEdit {
                Button(action: { action?() }) {
                    Text("Edit")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding(AppSpacing.md)
    }
}
