//
//  AvatarSelectionView.swift
//  SynthesiaAI
//

import SwiftUI

struct AvatarSelectionView: View {
    @ObservedObject var viewModel: CreateVideoViewModel
    @EnvironmentObject var appState: AppState
    @State private var showOnlyCustom = false
    
    var filteredAvatars: [Avatar] {
        var avatars: [Avatar]
        
        if showOnlyCustom {
            avatars = appState.customAvatars
        } else {
            avatars = appState.allAvatars
        }
        
        if let genderFilter = viewModel.avatarGenderFilter {
            avatars = avatars.filter { $0.gender == genderFilter }
        }
        
        if viewModel.avatarStyleFilter != .all {
            avatars = avatars.filter { $0.style == viewModel.avatarStyleFilter }
        }
        
        return avatars
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    headerSection
                    
                    filterSection
                    
                    avatarCountSection
                    
                    avatarContent
                    
                    errorSection
                }
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, 120)
            }
            
            bottomButton
        }
        .onAppear {
            if appState.presetAvatars.isEmpty {
                Task {
                    await appState.fetchPresetAvatars()
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("Choose Avatar")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            if appState.isLoadingAvatars {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Button(action: {
                    Task {
                        await appState.fetchPresetAvatars()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        VStack(spacing: AppSpacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    Chip(
                        title: "All Avatars",
                        icon: "✨",
                        isSelected: !showOnlyCustom && viewModel.avatarGenderFilter == nil
                    ) {
                        showOnlyCustom = false
                        viewModel.avatarGenderFilter = nil
                    }
                    
                    Chip(
                        title: "My Custom",
                        icon: "🎨",
                        isSelected: showOnlyCustom
                    ) {
                        showOnlyCustom = true
                    }
                    
                    Chip(
                        title: "Female",
                        icon: "👩",
                        isSelected: viewModel.avatarGenderFilter == .female
                    ) {
                        showOnlyCustom = false
                        viewModel.avatarGenderFilter = .female
                    }
                    
                    Chip(
                        title: "Male",
                        icon: "👨",
                        isSelected: viewModel.avatarGenderFilter == .male
                    ) {
                        showOnlyCustom = false
                        viewModel.avatarGenderFilter = .male
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(AvatarStyle.allCases, id: \.self) { style in
                        Chip(
                            title: style.rawValue,
                            isSelected: viewModel.avatarStyleFilter == style
                        ) {
                            viewModel.avatarStyleFilter = style
                        }
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Avatar Count Section
    private var avatarCountSection: some View {
        HStack {
            Text("\(filteredAvatars.count) avatars available")
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Avatar Content
    @ViewBuilder
    private var avatarContent: some View {
        if appState.isLoadingAvatars && filteredAvatars.isEmpty {
            loadingView
        } else if filteredAvatars.isEmpty {
            emptyView
        } else {
            avatarsGrid
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
            Text("Loading avatars...")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxxl)
    }
    
    private var emptyView: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 40))
                .foregroundColor(AppColors.textTertiary)
            
            Text("No avatars found")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Text("Try adjusting your filters or create a custom avatar")
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxxl)
    }
    
    private var avatarsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: AppSpacing.md),
            GridItem(.flexible(), spacing: AppSpacing.md)
        ], spacing: AppSpacing.md) {
            ForEach(filteredAvatars) { avatar in
                SelectableAvatarCard(
                    avatar: avatar,
                    isSelected: viewModel.selectedAvatar?.id == avatar.id
                ) {
                    viewModel.selectedAvatar = avatar
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
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
                disabled: !viewModel.canProceed
            ) {
                viewModel.nextStep()
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
    }
}

struct SelectableAvatarCard: View {
    let avatar: Avatar
    let isSelected: Bool
    let action: () -> Void

    private let cardWidth: CGFloat = 172
    private let cardHeight: CGFloat = 283
    private let infoHeight: CGFloat = 65

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                if let data = avatar.localImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                        .cornerRadius(AppRadius.medium)
                } else if let url = URL(string: avatar.imageURL), !avatar.imageURL.isEmpty {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: cardWidth, height: cardHeight)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .background(.white)
                                .frame(width: cardWidth, height: cardHeight)
                                .clipped()
                                .cornerRadius(AppRadius.medium)
                        case .failure:
                            placeholder
                        @unknown default:
                            placeholder
                        }
                    }
                } else {
                    placeholder
                }

                VStack {
                    Spacer()
                    avatarInfo
                        .frame(height: infoHeight)
                        .frame(maxWidth: .infinity)
                        .background(isSelected ? Color(hex: "346AEA") : Color.white)
                        .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
                }
            }
            .frame(width: cardWidth, height: cardHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var placeholder: some View {
        Rectangle()
            .fill(AppColors.primary.opacity(0.3))
            .overlay(
                Text(String(avatar.name.prefix(2)).uppercased())
                    .font(.title2.bold())
                    .foregroundColor(AppColors.primary)
            )
            .frame(width: cardWidth, height: cardHeight)
            .cornerRadius(AppRadius.medium)
    }

    private var avatarInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(avatar.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? Color.white : .black)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                if avatar.isCustom {
                    HStack {
                        Text("•")
                            .font(.system(size: 20))
                            .foregroundColor(isSelected ? Color.white : Color(hex: "346AEA"))
                        Text("\(avatar.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption2)
                            .foregroundColor(isSelected ? Color.white : .gray)
                    }
                } else {
                    Text(avatar.gender.rawValue)
                        .font(.caption2)
                        .foregroundColor(isSelected ? Color.white : .gray)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}
