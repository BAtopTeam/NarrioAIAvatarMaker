//
//  RateAppView.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI

struct RateAppView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xxxl) {
                Spacer()
                
                Image(.rateAvatar)
                
                VStack(spacing: AppSpacing.md) {
                    Text("Do you like our app?")
                        .font(AppTypography.title2)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Please rate our app so we can improve it for you and make it even cooler!")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xxl)
                }
                
                Spacer()
                
                HStack(spacing: AppSpacing.md) {
                    Button(action: { dismiss() }) {
                        Text("Later")
                            .font(AppTypography.buttonLarge)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppColors.background)
                            .cornerRadius(AppRadius.medium)
                    }
                    
                    Button(action: {
                        appState.requestReview()
                    }) {
                        Text("Rate now")
                            .font(AppTypography.buttonLarge)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(AppColors.primary)
                            .cornerRadius(AppRadius.medium)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxl)
            }
            .background(AppColors.background)
            .navigationTitle("Rate Us")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
    }
}
