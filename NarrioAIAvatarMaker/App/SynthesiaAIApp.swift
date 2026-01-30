//
//  SynthesiaAIApp.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI

@main
struct SynthesiaAIApp: App {
    @StateObject private var appState = AppState(currentUser: .mock)
    @StateObject private var videoGenerationVM = VideoGenerationViewModel()
    @StateObject private var videoGenerationManager = VideoGenerationManager()
    @StateObject var createVideoFlow = CreateVideoFlow()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Color.white)
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.primary)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppColors.primary)]
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.black)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.black)]
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(createVideoFlow)
                .environmentObject(videoGenerationManager)
                .environmentObject(appState)
                .environmentObject(videoGenerationVM)
                .onAppear {
                    appState.setup(videoGenerationManager: videoGenerationManager)
                }
        }
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil,
                   from: nil,
                   for: nil)
    }
}
