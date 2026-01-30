//
//  PaywallView.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI
import ApphudSDK

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @StateObject private var subManager = SubscriptionManager.shared
    @State private var selectedProduct: ApphudProduct?
    @State private var showCloseButton = false
    @State private var showRestoreError = false
    @State private var restoreErrorMessage = ""
    
    private var isSE: Bool {
        UIScreen.main.bounds.height <= 667
    }
    
    private let termsURL = URL(string:
        "https://docs.google.com/document/d/1AtwNpS7qxF2lSwFdsKOvXsVnhF1-SWKC3qvNvJgrbQ0/edit"
    )!

    private let privacyURL = URL(string:
        "https://docs.google.com/document/d/1xPM0DDi9umNM8Tv70FVnvUjvEUoYwb5WWhnkUSVltU8/edit"
    )!

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: AppSpacing.xxl) {
                        
                        featuresSection
                        
                        subscriptionOptions
                        
                        Text("Cancel anytime")
                            .font(.system(size: 15).bold())
                            .foregroundStyle(AppColors.textSecondary)
                        
                        PrimaryButton(
                            title: subManager.isLoading ? "Loading..." : "Continue",
                            disabled: selectedProduct == nil || subManager.isLoading
                        ) {
                            purchase()
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        termsSection
                        
                        Spacer()
                    }
                    .background(AppColors.paywallBackground)
                    .ignoresSafeArea()
                }
                
                if subManager.isLoading {
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
            .background(AppColors.paywallBackground)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .background(AppColors.paywallBackground)
        .alert("Restore Failed", isPresented: $showRestoreError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreErrorMessage)
        }
        .onAppear {
            subManager.loadProducts()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation { showCloseButton = true }
            }
        }
    }

    // MARK: - Features Section
    private var featuresSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image(.paywallAvatar)
                .offset(y: 16)
                .zIndex(1)
            VStack(spacing: AppSpacing.lg) {
                HStack(alignment: .top) {
                    Image(.first)
                    Spacer()
                    if showCloseButton {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                        }
                        .transition(.opacity)
                        .animation(.easeIn, value: showCloseButton)
                    }
                }
                HStack {
                    Spacer()
                    Image(.second)
                }
            }
            .padding(.top, 64)
            .padding(.horizontal, 16)
        }
        .padding(.bottom, AppSpacing.lg)
        .background(AppColors.paywallGradient)
    }

    // MARK: - Subscription Options
    private var subscriptionOptions: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Get Full Access")
                .font(.system(size: 22).bold())
                .foregroundStyle(.black)
            Text("Audio & Video edit without linites")
                .font(.system(size: 17))
                .foregroundStyle(.gray)
                .padding(.bottom, 16)
            
            // MARK: - Weekly
            if let weeklyProduct = subManager.products.first(where: {
                $0.productId.lowercased().contains("week")
            }) {
                SubscriptionOption(
                    name: "Weekly",
                    price: subManager.getPriceString(for: weeklyProduct) + " / week",
                    saving: nil,
                    perWeek: nil,
                    isSelected: selectedProduct?.productId == weeklyProduct.productId
                ) {
                    selectedProduct = weeklyProduct
                }
            }

            // MARK: - Annual
            if let annualProduct = subManager.products.first(where: {
                $0.productId.lowercased().contains("year")
            }) {
                SubscriptionOption(
                    name: "Yearly",
                    price: subManager.getPriceString(for: annualProduct) + " / year",
                    saving: "Save 86%",
                    perWeek: String(
                        format: "$%.2f / week",
                        subManager.getPriceValue(for: annualProduct) / 52
                    ),
                    isSelected: selectedProduct?.productId == annualProduct.productId
                ) {
                    selectedProduct = annualProduct
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }


    // MARK: - Terms Section
    private var termsSection: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: 24) {
                Link("Terms of Use", destination: termsURL)
                    .font(AppTypography.footnote)
                    .foregroundColor(AppColors.textSecondary)
                
                Button("Restore") {
                    subManager.restorePurchases { success, error in
                        if success {
                            dismiss()
                        } else {
                            restoreErrorMessage = error ?? "Failed to restore purchases"
                            showRestoreError = true
                        }
                    }
                }
                .font(AppTypography.footnote)
                .foregroundColor(AppColors.textSecondary)
                
                Link("Privacy Policy", destination: privacyURL)
                    .font(AppTypography.footnote)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .background(AppColors.paywallBackground)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    private func purchase() {
        guard let product = selectedProduct else { return }

        subManager.purchase(product: product) { success, error in
            if success {
                dismiss()
            } else {
                print("❌ Purchase failed:", error ?? "")
            }
        }
    }
}

// MARK: - Feature Item
struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(description)
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
        }
    }
}

// MARK: - Subscription Option
struct SubscriptionOption: View {
    let name: String
    let price: String
    let saving: String?
    let perWeek: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(name)
                            .font(AppTypography.headline)
                            .foregroundColor(isSelected ? AppColors.primary : AppColors.textPrimary)
                        
                        if let saving {
                            Text(saving)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.statBackground)
                                .cornerRadius(4)
                        }
                    }
                    if let perWeek {
                        Text(perWeek)
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 40) {
                    Rectangle()
                        .fill(Color.black.opacity(0.15))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                        .frame(height: 50)
    
                    Text(price)
                        .font(AppTypography.headline)
                        .foregroundColor(isSelected ? AppColors.primary : AppColors.textPrimary)
                }
            }
            .frame(height: 40)
            .padding(AppSpacing.lg)
            .background(AppColors.cardBackground)
            .cornerRadius(AppRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.large)
                    .stroke(isSelected ? AppColors.primary : Color.black.opacity(0.15), lineWidth: 2)
            )
        }
    }
}

