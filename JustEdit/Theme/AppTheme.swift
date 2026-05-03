import SwiftUI

// MARK: - App Theme

enum AppTheme {
    // MARK: - Colors

    static let primary = Color(hex: "6C63FF")
    static let primaryLight = Color(hex: "8B85FF")
    static let secondary = Color(hex: "FF6B6B")
    static let accent = Color(hex: "00D2FF")
    static let gold = Color(hex: "FFD93D")

    // Dark
    static let darkBackground = Color(hex: "0A0E21")
    static let darkSurface = Color(hex: "161B33")
    static let darkSurfaceSecondary = Color(hex: "1E2545")
    static let darkTextPrimary = Color.white
    static let darkTextSecondary = Color(hex: "A0A3BD")

    // Light
    static let lightBackground = Color(hex: "F8F9FE")
    static let lightSurface = Color.white
    static let lightSurfaceSecondary = Color(hex: "F0F1F5")
    static let lightTextPrimary = Color(hex: "1A1A2E")
    static let lightTextSecondary = Color(hex: "6B7280")

    // MARK: - Adaptive Colors

    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkBackground : lightBackground
    }

    static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkSurface : lightSurface
    }

    static func surfaceSecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkSurfaceSecondary : lightSurfaceSecondary
    }

    static func textPrimary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkTextPrimary : lightTextPrimary
    }

    static func textSecondary(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? darkTextSecondary : lightTextSecondary
    }

    // MARK: - Gradients

    static let primaryGradient = LinearGradient(
        colors: [primary, accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmGradient = LinearGradient(
        colors: [secondary, gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surfaceGradient = LinearGradient(
        colors: [Color(hex: "161B33"), Color(hex: "0A0E21")],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Shadows

    static let softShadow = Color.black.opacity(0.08)
    static let mediumShadow = Color.black.opacity(0.15)

    // MARK: - Dimensions

    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 10
    static let cornerRadiusTiny: CGFloat = 6
    static let toolbarHeight: CGFloat = 52
    static let keyboardHeight: CGFloat = 260
    static let iconSize: CGFloat = 20

    // MARK: - Animation

    static let quickAnimation = Animation.easeInOut(duration: 0.2)
    static let smoothAnimation = Animation.spring(response: 0.35, dampingFraction: 0.85)
}
