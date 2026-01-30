//
//  ContentView.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var videoGenerationVM: VideoGenerationViewModel
    @EnvironmentObject var videoGenerationManager: VideoGenerationManager
    @EnvironmentObject var createVideoFlow: CreateVideoFlow
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            Group {
                if !appState.hasCompletedOnboarding {
                    OnboardingView()
                        .environmentObject(appState)
                } else {
                    MainTabView()
                        .environmentObject(createVideoFlow)
                        .environmentObject(appState)
                        .environmentObject(videoGenerationManager)
                }
            }
            .fullScreenCover(isPresented: $appState.isShowingPaywall) {
                PaywallView()
                    .environmentObject(appState)
            }
            
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut, value: appState.hasCompletedOnboarding)
    }
}

