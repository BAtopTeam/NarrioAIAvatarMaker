//
//  ProfileView.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI
import StoreKit

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPaywall = false
    @State private var showLanguageSettings = false
    @State private var showVoiceSettings = false
    @State private var showClearHistoryAlert = false
    @StateObject private var subManager = SubscriptionManager.shared
    @Environment(\.openURL) private var openURL
    
    private let privacyURL = URL(string: "https://docs.google.com/document/d/1xPM0DDi9umNM8Tv70FVnvUjvEUoYwb5WWhnkUSVltU8/edit?usp=sharing")!
    private let termsURL = URL(string: "https://docs.google.com/document/d/1AtwNpS7qxF2lSwFdsKOvXsVnhF1-SWKC3qvNvJgrbQ0/edit?usp=sharing")!
    private let supportURL = URL(string: "https://forms.gle/4vgGvuFjPPqfBs2k9")!
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "v\(version) (\(build))"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.mainGradient
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: AppSpacing.xxl) {
                        if !subManager.isSubscribed {
                            subscriptionCard
                        }
                        
                        settingsSection
                        
                        legalSection
                        
                        Button {
                            showClearHistoryAlert = true
                        } label: {
                            Text("Clear history")
                                .foregroundStyle(Color(hex: "FF3B30"))
                                .font(.system(size: 16))
                        }
                        .alert("Are you sure?", isPresented: $showClearHistoryAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Confirm", role: .destructive) {
                                appState.clearAllData()
                            }
                        } message: {
                            Text("This will delete all your projects, avatars, and history. This action cannot be undone.")
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, 100)
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(isPresented: $showPaywall) {
                    PaywallView()
                }
            }
        }
        .onAppear {
            subManager.checkSubscriptionStatus()
        }
        .preferredColorScheme(.light)
    }
    
    // MARK: - Subscription Card
    private var subscriptionCard: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.currentUser.subscription.displayName)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
            }
            
            if !appState.currentUser.subscription.isPro {
                PrimaryButton(title: "Upgrade to Pro") {
                    showPaywall = true
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.top, AppSpacing.lg)
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Settings")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                
                SettingsRow(
                    icon: "star",
                    title: "Rate App"
                ) {
                    if let url = URL(string: "https://apps.apple.com/app/id6758341620?action=write-review") {
                        UIApplication.shared.open(url)
                    }
                }
                
                Divider().padding(.leading, 50)
                
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Support"
                ) {
                    openURL(supportURL)
                }
                
                Divider().padding(.leading, 50)
                
                SettingsRow(
                    icon: "envelope",
                    title: "Contact us"
                ) {
                    openURL(supportURL)
                }
                
                Divider().padding(.leading, 50)
                
                SettingsRow(
                    icon: "info.circle",
                    title: "App version",
                    value: appVersion,
                    showChevron: false
                )
            }
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
        }
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "doc.text",
                    title: "Privacy Policy"
                ) {
                    openURL(privacyURL)
                }
                
                Divider().padding(.leading, 50)
                
                SettingsRow(
                    icon: "doc.text",
                    title: "Terms of Use"
                ) {
                    openURL(termsURL)
                }
            }
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Support")
                .font(AppTypography.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "Help Center"
                ) {}
                
                Divider().padding(.leading, 50)
                
                SettingsRow(
                    icon: "lock.shield",
                    title: "Terms & Privacy"
                ) {}
            }
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
        }
    }
}

