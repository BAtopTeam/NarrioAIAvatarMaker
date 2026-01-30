//
//  OnboardingView.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showLaunch = true
    @State private var currentPage = 0
    
    let pages = OnboardingPage.pages
    
    var body: some View {
        ZStack {
            OnboardingPagesView(
                pages: pages,
                currentPage: $currentPage,
                onComplete: {
                    appState.completeOnboarding()
                }
            )
            .transition(.opacity)
        }
    }
}

// MARK: - Launch Screen
struct LaunchScreenView: View {
    var onComplete: () -> Void
    @State private var animateIcon = false
    @State private var animateText = false
    
    var body: some View {
        ZStack {
            AppColors.launchGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(animateIcon ? 1.1 : 1.0)
                    
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(animateIcon ? 10 : -10))
                }
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateIcon)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(AppColors.primary)
                        Text("Your Script")
                            .font(AppTypography.headline)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Text("Write or paste your video content")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textSecondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start typing your script here...")
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text("Example: Welcome! In this video, I'll show you how to create stunning AI-powered videos in just minutes using our platform.")
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(3)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.background)
                    .cornerRadius(AppRadius.medium)
                    
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Image(systemName: "waveform")
                            Text("0")
                        }
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("~0:00")
                        }
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.textTertiary)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("AI Improve Script")
                            Image(systemName: "arrow.right")
                        }
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.primary)
                        .cornerRadius(AppRadius.medium)
                    }
                }
                .padding(20)
                .background(.white)
                .cornerRadius(AppRadius.xl)
                .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                .padding(.horizontal, 24)
                .opacity(animateText ? 1 : 0)
                .offset(y: animateText ? 0 : 50)
                
                Spacer()
            }
        }
        .onAppear {
            animateIcon = true
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateText = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onComplete()
            }
        }
    }
}

// MARK: - Onboarding Pages
struct OnboardingPagesView: View {
    let pages: [OnboardingPage]
    @EnvironmentObject var appState: AppState
    @Binding var currentPage: Int
    var onComplete: () -> Void
    @StateObject private var subManager = SubscriptionManager.shared
    @State private var showRestoreError = false
    @State private var showRestore = false
    @State private var restoreMessage = ""
    
    private let termsURL = URL(string:
        "https://docs.google.com/document/d/1AtwNpS7qxF2lSwFdsKOvXsVnhF1-SWKC3qvNvJgrbQ0/edit"
    )!

    private let privacyURL = URL(string:
        "https://docs.google.com/document/d/1xPM0DDi9umNM8Tv70FVnvUjvEUoYwb5WWhnkUSVltU8/edit"
    )!
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageContent(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            VStack(spacing: 14) {
                PrimaryButton(title: "Continue") {
                    if currentPage == 1 {
                        appState.requestIDFAPermission()
                    }
                    if currentPage == 2 {
                        appState.requestRating()
                    }
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onComplete()
                    }
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 16) {
                    Link("Terms of Use", destination: termsURL)
                    Button("Restore") {
                        subManager.restorePurchases { success, error in
                            if success {
                                restoreMessage = error ?? "Purchases restored successfully ✅"
                                showRestore = true
                            } else {
                                restoreMessage = error ?? "Failed to restore purchases"
                                showRestoreError = true
                            }
                        }
                    }
                    Link("Privacy Policy", destination: privacyURL)
                }
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.textSecondary)
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            subManager.checkSubscriptionStatus()
        }
        .background(Color.white)
        .alert("Restore", isPresented: $showRestore) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage)
        }
        .alert("Restore Failed", isPresented: $showRestoreError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage)
        }
    }
}


// MARK: - Onboarding Page Content
struct OnboardingPageContent: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 16)
            
            Group {
                if page.title == "Create" {
                    AvatarCreationPreview()
                } else if page.title == "We value" {
                    FeedbackPreview()
                } else if page.title == "Exclusive" {
                    FeaturesPreview()
                } else {
                    UserChoicePreview()
                }
            }
            .scaleEffect(0.9)
            
            VStack(spacing: verticalSpacing) {
                VStack(spacing: innerSpacing) {
                    Text(page.title)
                        .font(titleFont)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(minScale)
                        .lineLimit(2)

                    Text(page.highlightedText)
                        .font(titleFont)
                        .foregroundColor(AppColors.primary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(minScale)
                        .lineLimit(2)
                }

                Text(page.description)
                    .font(descriptionFont)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, horizontalPadding)
                    .minimumScaleFactor(minScale)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true) 
            }
            
            Spacer(minLength: 24)
        }
    }
    
    // MARK: - Adaptive values
    private var verticalSpacing: CGFloat {
        UIScreen.main.bounds.width <= 375 ? 6 : 8
    }

    private var innerSpacing: CGFloat {
        UIScreen.main.bounds.width <= 375 ? 1 : 2
    }

    private var titleFont: Font {
        UIScreen.main.bounds.width <= 375 ? AppTypography.title3 : AppTypography.title1
    }

    private var descriptionFont: Font {
        UIScreen.main.bounds.width <= 375 ? AppTypography.callout : AppTypography.body
    }

    private var horizontalPadding: CGFloat {
        UIScreen.main.bounds.width <= 375 ? 12 : 24
    }

    private var minScale: CGFloat {
        UIScreen.main.bounds.width <= 375 ? 0.85 : 1.0
    }
}


// MARK: - UserChoicePreview
struct UserChoicePreview: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isSmallScreen: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular && UIScreen.main.bounds.width <= 375
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: verticalSizeClass == .compact ? 6 : 12) {
                if isSmallScreen {
                    Image(.yourScript)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: verticalSizeClass == .compact ? 80 : 150)
                    
                    Image(.scriptButton)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: verticalSizeClass == .compact ? 30 : 60)
                } else {
                    Image(.yourScript)
                    
                    Image(.scriptButton)
                }
            }
            .padding(.top, verticalSizeClass == .compact ? 6 : 12)
            .padding(.trailing, verticalSizeClass == .compact ? 6 : 12)
            if isSmallScreen {
                Image(.onboardAvatar)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: verticalSizeClass == .compact ? 120 : 220)
                    .offset(y: verticalSizeClass == .compact ? 10 : 20)
            } else {
                Image(.onboardAvatar)
                    .offset(y: verticalSizeClass == .compact ? 10 : 20)
            }
            
            LinearGradient(
                colors: [.clear, .white],
                startPoint: .top,
                endPoint: .bottom
            )
            .offset(y: verticalSizeClass == .compact ? 10 : 20)
            .frame(height: verticalSizeClass == .compact ? 60 : 100)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .allowsHitTesting(false)
        }
    }
}

// MARK: - AvatarCreationPreview
struct AvatarCreationPreview: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isSmallScreen: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular && UIScreen.main.bounds.width <= 375
    }
    
    var body: some View {
        VStack(spacing: verticalSizeClass == .compact ? 6 : 12) {
            HStack {
                Text("Your Custom Avatars")
                    .font(verticalSizeClass == .compact ? AppTypography.title3 : AppTypography.title2)
                    .foregroundColor(.black)
                Spacer()
            }
            if isSmallScreen {
                Image(.avatars)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: verticalSizeClass == .compact ? 120 : 220)
            } else {
                Image(.avatars)
            }
             
            ZStack(alignment: .bottom) {
                if isSmallScreen {
                    Image(.photoGuide)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: verticalSizeClass == .compact ? 100 : 180)
                } else {
                    Image(.photoGuide)
                }
                
                LinearGradient(
                    colors: [.clear, .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: verticalSizeClass == .compact ? 60 : 100)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .allowsHitTesting(false)
            }
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - FeedbackPreview
struct FeedbackPreview: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isSmallScreen: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular && UIScreen.main.bounds.width <= 375
    }
    
    var body: some View {
        VStack(spacing: verticalSizeClass == .compact ? 8 : 16) {
            if isSmallScreen {
                Image(.highest)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: verticalSizeClass == .compact ? 100 : 180)
                
                Image(.lisaM)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: verticalSizeClass == .compact ? 100 : 180)
            } else {
                Image(.highest)
                Image(.lisaM)
            }
        }
    }
}

// MARK: - FeaturesPreview
struct FeaturesPreview: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.sizeCategory) private var sizeCategory

    var body: some View {
        VStack(spacing: spacing) {
            Text("All-in-One")
                .font(titleFont)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(minScale)

            Text("VideoCreator AI Tools")
                .font(titleFont)
                .foregroundColor(AppColors.primary)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(minScale)

            VStack(alignment: .leading, spacing: rowSpacing) {
                FeatureRow(icon: "🎬", title: "Unlimited Video Creation",
                           description: "Create as many AI videos as you want – no limits, no generation caps")
                FeatureRow(icon: "🧠", title: "Advanced Script & Scene Control",
                           description: "Refine scripts, pacing, and structure with smart AI-assisted editing tools")
                FeatureRow(icon: "🧍", title: "Premium Avatars & Voices",
                           description: "Unlock a wider range of realistic avatars, voices, and accents")
                FeatureRow(icon: "📊", title: "Exclusive Sync Support",
                           description: "Quickly and securely transfer data between devices")
                FeatureRow(icon: "⚡", title: "Priority AI Updates",
                           description: "Stay ahead with the latest model upgrades and scam detection")
            }
        }
        .padding(padding)
    }

    // MARK: - Adaptive values
    private var spacing: CGFloat {
        verticalSizeClass == .compact ? 4 : 8
    }

    private var rowSpacing: CGFloat {
        verticalSizeClass == .compact ? 2 : 6
    }

    private var padding: CGFloat {
        verticalSizeClass == .compact ? 8 : 16
    }

    private var titleFont: Font {
        verticalSizeClass == .compact ? AppTypography.title3 : AppTypography.title2
    }

    private var minScale: CGFloat {
        verticalSizeClass == .compact ? 0.85 : 1.0
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isSmallScreen: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular && UIScreen.main.bounds.width <= 375
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(icon)
                .font(isSmallScreen ? AppTypography.title3 : AppTypography.title2)
                .foregroundColor(AppColors.primary)
            
            VStack(alignment: .leading, spacing: isSmallScreen ? 1 : 2) {
                Text(title)
                    .font(isSmallScreen ? AppTypography.title4 : AppTypography.title3)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(isSmallScreen ? AppTypography.caption1 : AppTypography.callout)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true) 
            }
        }
    }
}
