//
//  MainTabView.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var createVideoFlow: CreateVideoFlow
    @EnvironmentObject var videoGenerationManager: VideoGenerationManager
    
    var body: some View {
        ZStack {
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tabItem {
                        Label(TabItem.home.rawValue, systemImage: appState.selectedTab == .home ? TabItem.home.selectedIcon : TabItem.home.icon)
                    }
                    .environmentObject(videoGenerationManager)
                    .environmentObject(appState)
                    .environmentObject(createVideoFlow)
                    .tag(TabItem.home)
                
                AvatarsView()
                    .tabItem {
                        Label(TabItem.avatars.rawValue, systemImage: appState.selectedTab == .avatars ? TabItem.avatars.selectedIcon : TabItem.avatars.icon)
                    }
                    .environmentObject(videoGenerationManager)
                    .environmentObject(appState)
                    .environmentObject(createVideoFlow)
                    .tag(TabItem.avatars)
                
                ProjectsView()
                    .tabItem {
                        Label(TabItem.projects.rawValue, systemImage: appState.selectedTab == .projects ? TabItem.projects.selectedIcon : TabItem.projects.icon)
                    }
                    .environmentObject(videoGenerationManager)
                    .environmentObject(appState)
                    .tag(TabItem.projects)
                
                ProfileView()
                    .tabItem {
                        Label(TabItem.profile.rawValue, systemImage: appState.selectedTab == .profile ? TabItem.profile.selectedIcon : TabItem.profile.icon)
                    }
                    .environmentObject(videoGenerationManager)
                    .environmentObject(appState)
                    .tag(TabItem.profile)
            }
            .tint(AppColors.primary)
        }
    }
}
