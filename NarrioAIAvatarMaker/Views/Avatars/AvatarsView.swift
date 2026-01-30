//
//  AvatarsView.swift
//  SynthesiaAI
//

import SwiftUI

struct AvatarsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = AvatarsViewModel()
    @State private var selectedAvatar: Avatar? = nil
    @EnvironmentObject var createVideoFlow: CreateVideoFlow
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.mainGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.xxl) {
                        createAvatarCard
                        statsRow
                        
                        if !appState.customAvatars.isEmpty {
                            customAvatarsSection
                        } else {
                            emptyCustomAvatarsSection
                        }
                        
                        if !appState.presetAvatars.isEmpty {
                            presetAvatarsSection
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, 100)
                }
                .preferredColorScheme(.light)
                .navigationTitle("Avatars")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if appState.isLoadingAvatars {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Button(action: {
                                Task {
                                    await viewModel.refreshAvatars(appState: appState)
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showCreateAvatar) {
                    CreateAvatarView()
                        .environmentObject(appState)
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            Task {
                await viewModel.loadInitialData(appState: appState)
            }
        }
    }
    
    // MARK: - Create Avatar Card
    private var createAvatarCard: some View {
        Button(action: { viewModel.showCreateAvatar = true }) {
            HStack(spacing: AppSpacing.lg) {
                Image(.createAvatar)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create Custom Avatar")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Turn your photo into an AI avatar in seconds")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .padding(.top, AppSpacing.lg)
    }
    
    // MARK: - Stats Row
    private var statsRow: some View {
        HStack(spacing: AppSpacing.md) {
            AvatarStatCard(
                icon: "person.crop.circle",
                value: "\(appState.allAvatars.count)",
                label: "Total Avatars"
            )
            
            AvatarStatCard(
                icon: "sparkles",
                value: "\(appState.customAvatars.count)",
                label: "Custom Avatars"
            )
        }
    }
    
    // MARK: - Custom Avatars Section
    private var customAvatarsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Your Custom Avatars")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: AppSpacing.md),
                GridItem(.flexible(), spacing: AppSpacing.md)
            ], spacing: AppSpacing.md) {
                ForEach(appState.customAvatars) { avatar in
                    AvatarCard(avatar: avatar)
                        .onTapGesture {
                            createVideoFlow.open(avatar: avatar)
                        }
                }
            }
        }
    }
    
    // MARK: - Empty Custom Avatars
    private var emptyCustomAvatarsSection: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Your Custom Avatars")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: AppSpacing.md) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 48))
                    .foregroundColor(AppColors.textTertiary)
                
                Text("Empty")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Start crafting your unique Custom Avatar by tapping the button below")
                    .font(AppTypography.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button(action: { viewModel.showCreateAvatar = true }) {
                    Text("Create")
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(AppColors.primary)
                        .cornerRadius(AppRadius.medium)
                }
            }
            .padding(AppSpacing.xxl)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
        }
    }
    
    // MARK: - Preset Avatars Section (from API)
    private var presetAvatarsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack {
                Text("AI Preset Avatars")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(appState.presetAvatars.count)")
                    .font(AppTypography.caption1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.primary)
                    .cornerRadius(AppRadius.small)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: AppSpacing.md),
                GridItem(.flexible(), spacing: AppSpacing.md)
            ], spacing: AppSpacing.md) {
                ForEach(appState.presetAvatars.prefix(6)) { avatar in
                    APIAvatarCard(avatar: avatar)
                        .onTapGesture {
                            createVideoFlow.open(avatar: avatar)
                        }
                }
            }
            
            if appState.presetAvatars.count > 6 {
                NavigationLink {
                    AllPresetAvatarsView()
                        .environmentObject(appState)
                } label: {
                    HStack {
                        Text("View all \(appState.presetAvatars.count) avatars")
                        Image(systemName: "arrow.right")
                    }
                    .font(AppTypography.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - API Avatar Card (with image loading)
struct APIAvatarCard: View {
    let avatar: Avatar
    
    private let cardWidth: CGFloat = 172
    private let cardHeight: CGFloat = 283
    private let infoHeight: CGFloat = 65
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
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
            }
            
            avatarInfo
                .frame(height: infoHeight)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
        }
        .background(.white)
        .frame(width: cardWidth, height: cardHeight)
        .cornerRadius(AppRadius.medium)
        .contentShape(Rectangle())
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
                    .fontWeight(.regular)
                    .foregroundColor(.black)
                    .lineLimit(nil)
                
                Text(avatar.gender.rawValue)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Avatar Stat Card
struct AvatarStatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.primary)
            
            Text(value)
                .font(AppTypography.title2)
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Avatar Card
struct AvatarCard: View {
    let avatar: Avatar
    
    private let cardWidth: CGFloat = 172
    private let cardHeight: CGFloat = 283
    private let infoHeight: CGFloat = 65
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
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
                
                if avatar.isCustom {
                    VStack {
                        HStack {
                            Text("+ Custom")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.primary)
                                .cornerRadius(4)
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding(8)
                }
            }
            
            avatarInfo
                .frame(height: infoHeight)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
        }
        .frame(width: cardWidth, height: cardHeight)
        .contentShape(Rectangle())
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
                    .fontWeight(.regular)
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                if avatar.isCustom {
                    HStack {
                        Text("•")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "346AEA"))
                        Text("\(avatar.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                } else {
                    Text(avatar.gender.rawValue)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

struct AllPresetAvatarsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.mainGradient
                .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: AppSpacing.md),
                    GridItem(.flexible(), spacing: AppSpacing.md)
                ], spacing: AppSpacing.md) {
                    ForEach(appState.presetAvatars) { avatar in
                        APIAvatarCard(avatar: avatar)
                            .onTapGesture {
                                appState.selectedAvatar = avatar
                                dismiss()
                            }
                    }
                }
                .padding(AppSpacing.lg)
            }
            .navigationTitle("AI Preset Avatars")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
