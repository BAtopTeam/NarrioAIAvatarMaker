//
//  BackgroundSelectionView.swift
//  SynthesiaAI
//

import SwiftUI

struct BackgroundSelectionView: View {
    @ObservedObject var viewModel: CreateVideoViewModel
    @State private var selectedType: BackgroundType = .all
    
    var filteredBackgrounds: [Background] {
        if selectedType == .all {
            return Background.backgrounds
        }
        return Background.backgrounds.filter { $0.type == selectedType }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    headerSection
                    
                    backgroundsGrid
                    
                    if viewModel.selectedBackground != nil {
                        previewSection
                    }
                }
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, 120)
            }
            
            bottomButton
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            HStack {
                Image(systemName: "paintpalette")
                    .foregroundColor(AppColors.primary)
                Text("Background")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                ForEach(BackgroundType.allCases, id: \.self) { type in
                    Button(action: { selectedType = type }) {
                        Text(type.rawValue)
                            .font(AppTypography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(selectedType == type ? .white : AppColors.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selectedType == type ? AppColors.primary : AppColors.background)
                            .cornerRadius(AppRadius.full)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Backgrounds Grid
    private var backgroundsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: AppSpacing.md),
            GridItem(.flexible(), spacing: AppSpacing.md),
            GridItem(.flexible(), spacing: AppSpacing.md),
            GridItem(.flexible(), spacing: AppSpacing.md)
        ], spacing: AppSpacing.md) {
            ForEach(filteredBackgrounds) { background in
                BackgroundCard(
                    background: background,
                    isSelected: viewModel.selectedBackground?.id == background.id,
                    action: { viewModel.selectedBackground = background }
                )
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Preview Section
    @ViewBuilder
    private var previewSection: some View {
        if let selectedBackground = viewModel.selectedBackground {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(AppColors.primary)
                    Text("Preview")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                ZStack {
                    if selectedBackground.type == .gradient {
                        LinearGradient(
                            colors: selectedBackground.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        selectedBackground.colors.first ?? Color.white
                    }
                }
                .frame(height: 200)
                .cornerRadius(AppRadius.large)
            }
            .padding(.horizontal, AppSpacing.lg)
        }
    }
    
    // MARK: - Bottom Button
    private var bottomButton: some View {
        VStack {
            PrimaryButton(
                title: viewModel.currentStep.nextButtonTitle,
                icon: "arrow.right",
                disabled: !viewModel.canProceed
            ) {
                viewModel.nextStep()
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
    }
}

// MARK: - Background Card
struct BackgroundCard: View {
    let background: Background
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if background.type == .gradient {
                        LinearGradient(
                            colors: background.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        background.colors.first ?? Color.white
                    }
                }
                .frame(width: 70, height: 70)
                .cornerRadius(AppRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.medium)
                        .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 3)
                )
                .overlay(
                    Group {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppColors.primary)
                                .background(Circle().fill(.white))
                        }
                    }
                )
                
                Text(background.name)
                    .font(AppTypography.caption2)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
        }
    }
}
