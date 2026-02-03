//
//  Components.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isLoading: Bool = false
    var disabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Text(title)
                        .font(AppTypography.buttonLarge)
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                disabled ? Color.gray.opacity(0.5) : AppColors.primary
            )
            .cornerRadius(AppRadius.medium)
        }
        .disabled(disabled || isLoading)
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(AppTypography.buttonLarge)
            }
            .foregroundColor(AppColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .stroke(AppColors.primary.opacity(0.3), lineWidth: 1.5)
            )
            .cornerRadius(AppRadius.medium)
        }
    }
}

// MARK: - Card View
struct CardView<Content: View>: View {
    var padding: CGFloat = AppSpacing.lg
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(padding)
        .background(AppColors.cardBackground)
        .cornerRadius(AppRadius.large)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Icon Badge
struct IconBadge: View {
    let icon: String
    var color: Color = AppColors.primary
    var size: CGFloat = 44
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: size, height: size)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Avatar Image
struct AvatarImage: View {
    let name: String
    var size: CGFloat = 60
    var isCustom: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [AppColors.primary.opacity(0.3), AppColors.accent.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: size, height: size)
            
            Text(String(name.prefix(2)).uppercased())
                .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.primary)
            
            if isCustom {
                VStack {
                    HStack {
                        Spacer()
                        Text("+ Custom")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppColors.primary)
                            .cornerRadius(4)
                    }
                    Spacer()
                }
                .frame(width: size, height: size)
                .offset(x: 4, y: -4)
            }
        }
    }
}

// MARK: - Chip / Tag
struct Chip: View {
    let title: String
    var icon: String? = nil
    var iconResource: ImageResource? = nil
    var isSelected: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Text(icon)
                        .font(.system(size: 12))
                }
                if let imageResource = iconResource {
                    Image(imageResource)
                        .renderingMode(.template)
                        .foregroundStyle(isSelected ? .white : Color(hex: "007AFF"))
                }
                Text(title)
                    .font(AppTypography.caption1)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : AppColors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? AppColors.primary : AppColors.filterBackground)
            .cornerRadius(AppRadius.full)
        }
        .disabled(action == nil)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            HStack(spacing: AppSpacing.sm) {
                Image(.recent)
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Text(actionTitle)
                            .font(AppTypography.subheadline)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.black)
                }
            }
        }
    }
}

// MARK: - Progress Steps
struct StepIndicator: View {
    let totalSteps: Int
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? AppColors.primary : AppColors.primary.opacity(0.2))
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textTertiary)
            
            TextField(placeholder, text: $text)
                .font(AppTypography.body)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.background)
        .cornerRadius(AppRadius.medium)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: ProjectStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(AppTypography.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color)
            .cornerRadius(AppRadius.small)
    }
}

// MARK: - Action Button Row
struct ActionButtonRow: View {
    struct ActionItem: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let isPrimary: Bool
        let action: () -> Void
    }
    
    let actions: [ActionItem]
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ForEach(actions) { action in
                Button(action: action.action) {
                    VStack(spacing: 6) {
                        ZStack {
                            RoundedRectangle(cornerRadius: AppRadius.medium)
                                .fill(action.isPrimary ? AppColors.primary : AppColors.background)
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: action.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(action.isPrimary ? .white : AppColors.textPrimary)
                        }
                        
                        Text(action.title)
                            .font(AppTypography.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var showChevron: Bool = true
    var iconColor: Color = AppColors.primary
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.md)
        }
        .disabled(action == nil)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(AppColors.textTertiary)
            
            Text(title)
                .font(AppTypography.title3)
                .foregroundColor(AppColors.textPrimary)
            
            Text(description)
                .font(AppTypography.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.xxl)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppColors.primary)
                        .cornerRadius(AppRadius.medium)
                }
            }
        }
        .padding(AppSpacing.xxxl)
    }
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
        }
    }
    
    private func loadImage() async {
        let key = url.absoluteString
        
        if let cached = ImageCache.shared.image(forKey: key) {
            image = cached
            return
        }
        
        if let disk = DiskImageCache.shared.image(forKey: key) {
            ImageCache.shared.set(disk, forKey: key)
            image = disk
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                ImageCache.shared.set(uiImage, forKey: key)
                DiskImageCache.shared.save(uiImage, forKey: key)
                image = uiImage
            }
        } catch {
            print("❌ Image load error:", error)
        }
    }
}

struct BottomSheetView<Content: View>: View {
    let content: Content
    let onDismiss: (() -> Void)?
    
    init(onDismiss: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 16) {
                content
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16, corners: [.topLeft, .topRight])
            .shadow(radius: 10)
            .transition(.move(edge: .bottom))
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(
            Color.black.opacity(0.3)
                .onTapGesture { onDismiss?() }
        )
    }
}
