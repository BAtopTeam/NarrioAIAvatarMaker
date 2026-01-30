//
//  AppColors.swift
//  SynthesiaAI
//
//  Created on 2026-01-13.
//

import SwiftUI

struct AppColors {
    // MARK: - Primary Colors
    static let primary = Color(hex: "4A7DFF")
    static let primaryDark = Color(hex: "3366FF")
    static let primaryLight = Color(hex: "6B9AFF")
    
    // MARK: - Secondary Colors
    static let secondary = Color(hex: "5856D6")
    static let accent = Color(hex: "667eea")
    
    // MARK: - Background Colors
    static let background = Color(hex: "F8F9FA")
    static let cardBackground = Color.white
    static let paywallBackground = Color(hex: "F2F2F2")
    static let statBackground = Color(hex: "346AEA")
    static let darkBackground = Color(hex: "1a1a2e")
    
    // MARK: - Text Colors
    static let textPrimary = Color(hex: "1A1A2E")
    static let redText = Color(hex: "EF4444")
    static let textSecondary = Color(hex: "6B7280")
    static let textTertiary = Color(hex: "9CA3AF")
    
    // MARK: - Status Colors
    static let success = Color(hex: "10B981")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "EF4444")
    static let info = Color(hex: "3B82F6")
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [primary, primaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let launchGradient = LinearGradient(
        colors: [Color(hex: "4A7DFF"), Color(hex: "667eea")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let mainGradient = LinearGradient(
        colors: [Color(hex: "E4EAFF"), Color(hex: "72BCF3")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let paywallGradient = LinearGradient(
        colors: [Color(hex: "0149FF"), Color(hex: "0188FF")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color(hex: "4A7DFF").opacity(0.1), Color(hex: "667eea").opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let progressGradient = LinearGradient(
        colors: [Color(hex: "4A7DFF"), Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - App Typography
struct AppTypography {
    // MARK: - Headings
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let title4 = Font.system(size: 16, weight: .semibold, design: .rounded)
    
    // MARK: - Body
    static let headline = Font.system(size: 17, weight: .semibold)
    static let body = Font.system(size: 17, weight: .regular)
    static let callout = Font.system(size: 16, weight: .regular)
    static let subheadline = Font.system(size: 15, weight: .regular)
    static let footnote = Font.system(size: 13, weight: .regular)
    static let caption1 = Font.system(size: 12, weight: .regular)
    static let caption2 = Font.system(size: 11, weight: .regular)
    
    // MARK: - Buttons
    static let buttonLarge = Font.system(size: 17, weight: .semibold)
    static let buttonMedium = Font.system(size: 15, weight: .semibold)
    static let buttonSmall = Font.system(size: 13, weight: .semibold)
}

// MARK: - App Spacing
struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - App Radius
struct AppRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let full: CGFloat = 100
}
