//
//  HomeView.swift
//  SynthesiaAI
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var subManager = SubscriptionManager.shared
    @EnvironmentObject var createVideoFlow: CreateVideoFlow
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.mainGradient
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: AppSpacing.xxl) {
                        HStack {
                            statsSection
                            Spacer()
                        }
                        
                        createVideoCard
                        if !appState.recentVideos.isEmpty {
                            recentVideosSection
                        }
                        
                        templatesSection
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, 100)
                }
                .navigationBarHidden(true)
                .fullScreenCover(isPresented: $createVideoFlow.isPresented) {
                    CreateVideoView(viewModel: createVideoFlow.viewModel)
                        .environmentObject(appState)
                }
            }
        }
        .onAppear {
            subManager.checkSubscriptionStatus()
        }
        .preferredColorScheme(.light)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: AppSpacing.md) {
            StatChip(
                icon: "video",
                value: "\(appState.totalVideosCount)",
                label: "Videos"
            )
            
            StatChip(
                icon: "chart.line.uptrend.xyaxis",
                value: "\(appState.videosCreatedThisWeek)",
                label: "This Week"
            )
        }
        .padding(.top, 15)
    }
    
    // MARK: - Create Video Card
    private var createVideoCard: some View {
        Button(action: { createVideoFlow.open() }) {
            HStack(spacing: AppSpacing.lg) {
                Image(.creative)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create New Video")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Turn your ideas into reality in minutes")
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
    }
    
    // MARK: - Recent Videos Section
    private var recentVideosSection: some View {
        VStack(spacing: AppSpacing.lg) {
            SectionHeader(title: "Recent Videos", actionTitle: "View All") {
                viewModel.navigateToProjects(appState: appState)
            }
            
            VStack(spacing: AppSpacing.md) {
                ForEach(appState.recentVideos) { project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        RecentVideoCard(project: project)
                    }
                }
            }
        }
    }
    
    // MARK: - Templates Section
    private var templatesSection: some View {
        VStack(spacing: AppSpacing.lg) {
            SectionHeader(title: "Quick Start Templates")
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: AppSpacing.md),
                GridItem(.flexible(), spacing: AppSpacing.md)
            ], spacing: AppSpacing.md) {
                ForEach(appState.templates) { template in
                    TemplateCard(template: template) {
                        createVideoFlow.open(template: template, startStep: .preview)
                    }
                }
            }
        }
    }
}

// MARK: - Stat Chip
struct StatChip: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.primary)
            
            Text(value)
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppColors.statBackground.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.full)
                .stroke(AppColors.statBackground.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(AppRadius.full)
    }
}

// MARK: - Recent Video Card
struct RecentVideoCard: View {
    let project: Project
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                if !project.thumbnailURL.isEmpty,
                   let url = URL(string: project.thumbnailURL) {

                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .cornerRadius(AppRadius.medium)
                    } placeholder: {
                        Color.black.opacity(0.2)
                    }
                    .frame(width: 80, height: 60)
                    .clipped()
                    .cornerRadius(AppRadius.medium)
                } else {
                    RoundedRectangle(cornerRadius: AppRadius.medium)
                        .fill(LinearGradient(
                            colors: [AppColors.primary.opacity(0.3), AppColors.accent.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 60)
                }
                
                Image(systemName: "play.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(project.formattedDuration)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                            .padding(4)
                    }
                }
                .frame(width: 80, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(project.title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 8) {
                    StatusBadge(status: project.status)
                    
                    Text(project.formattedDate)
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: VideoTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                if !template.avatar.thumbnailURL.isEmpty,
                   let url = URL(string: template.avatar.thumbnailURL) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppRadius.medium)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary.opacity(0.2), AppColors.accent.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 172, height: 113)
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(AppRadius.medium)
                                    .clipped()
                                    .frame(width: 172, height: 113)
                            case .failure:
                                RoundedRectangle(cornerRadius: AppRadius.medium)
                                    .fill(LinearGradient(
                                        colors: [AppColors.primary.opacity(0.4), AppColors.accent.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(height: 113)
                            @unknown default:
                                RoundedRectangle(cornerRadius: AppRadius.medium)
                                    .fill(LinearGradient(
                                        colors: [AppColors.primary.opacity(0.4), AppColors.accent.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(height: 113)
                            }
                        }
                        .frame(width: 172, height: 113)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium))
                    }
                } else {
                    RoundedRectangle(cornerRadius: AppRadius.medium)
                        .fill(LinearGradient(
                            colors: [AppColors.primary.opacity(0.4), AppColors.accent.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 113)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.category)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.primary)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(template.title)
                        .font(AppTypography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(template.duration)
                        .font(AppTypography.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(AppSpacing.md)
            }
            .frame(height: 113)
        }
    }
}
