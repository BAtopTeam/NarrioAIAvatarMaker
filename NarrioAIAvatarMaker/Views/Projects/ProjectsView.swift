//
//  ProjectsView.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var showSearch = false
    
    var filteredProjects: [Project] {
        if searchText.isEmpty {
            return appState.projects
        }
        return appState.projects.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.mainGradient
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    if showSearch {
                        VStack(spacing: AppSpacing.md) {
                            HStack {
                                Button(action: {
                                    showSearch = false
                                    searchText = ""
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                
                                Spacer()
                                
                                Text("Search")
                                    .font(AppTypography.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.clear)
                            }
                            
                            SearchBar(text: $searchText, placeholder: "Search projects...")
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                    } else {
                        HStack {
                            SearchBar(text: $searchText, placeholder: "Search projects...")
                                .onTapGesture {
                                    showSearch = true
                                }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.vertical, AppSpacing.md)
                    }
                    
                    ScrollView {
                        if appState.projects.isEmpty {
                            EmptyStateView(
                                icon: "folder",
                                title: "No projects yet",
                                description: "Create your first project to start working."
                            )
                            .padding(.top, 80)
                            
                        } else if filteredProjects.isEmpty {
                            EmptyStateView(
                                icon: "magnifyingglass",
                                title: "Nothing found",
                                description: "Try changing your search query."
                            )
                            .padding(.top, 80)
                            
                        } else {
                            LazyVStack(spacing: AppSpacing.lg) {
                                ForEach(filteredProjects) { project in
                                    if project.status == .ready || project.status == .failed {
                                        NavigationLink(destination: ProjectDetailView(project: project)) {
                                            ProjectCard(project: project)
                                        }
                                    } else {
                                        ProjectCard(project: project)
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.top, AppSpacing.lg)
                            .padding(.bottom, 100)
                        }
                    }
                }
                .navigationTitle("Projects")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.white, for: .navigationBar) 
                .toolbarBackground(.visible, for: .navigationBar)
            }
        }
        .onTapGesture {
            UIApplication.shared.hideKeyboard()
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Project Card
struct ProjectCard: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(AppRadius.medium)
                } else {
                    RoundedRectangle(cornerRadius: AppRadius.medium)
                        .fill(LinearGradient(
                            colors: [AppColors.primary.opacity(0.4), AppColors.accent.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 160)
                }
                
                Circle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "play.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    )
                
                VStack {
                    HStack {
                        StatusBadge(status: project.status)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text(project.formattedDuration)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                    }
                }
                .padding(AppSpacing.md)
            }
            .cornerRadius(AppRadius.medium)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.avatarName)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(project.formattedDate)
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, AppSpacing.md)
                Spacer()
                if project.status == .inProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                        .scaleEffect(0.8)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
