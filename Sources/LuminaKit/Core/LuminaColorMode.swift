import SwiftUI

/// Controls how the loader adapts its colors to light/dark mode.
public enum LuminaColorMode: Sendable {

    /// Automatically follows the system's current appearance
    /// (`colorScheme` in SwiftUI, `traitCollection` in UIKit).
    case auto

    /// Forces light-mode colors (white glow). Use on light backgrounds.
    case light

    /// Forces dark-mode colors (soft blue-white glow). Use on dark backgrounds.
    case dark
}

// MARK: - Resolved Colors

/// Internal resolved color set used by all loader views.
struct LuminaResolvedColors {
    let bubbleFill: Color
    let bubbleShadow: Color
    let strokeColor: Color
    let strokeGlow: Color
    let progressTrack: Color

    /// Resolves colors based on the color mode and current color scheme.
    static func resolve(mode: LuminaColorMode, colorScheme: ColorScheme) -> LuminaResolvedColors {
        let isDark: Bool
        switch mode {
        case .auto:
            isDark = colorScheme == .dark
        case .light:
            isDark = false
        case .dark:
            isDark = true
        }

        if isDark {
            return LuminaResolvedColors(
                bubbleFill: Color(white: 0.9).opacity(0.85),
                bubbleShadow: Color(.systemBlue).opacity(0.4),
                strokeColor: Color(white: 0.85),
                strokeGlow: Color(.systemBlue).opacity(0.3),
                progressTrack: Color(white: 0.4).opacity(0.2)
            )
        } else {
            return LuminaResolvedColors(
                bubbleFill: Color.white.opacity(0.8),
                bubbleShadow: Color.white.opacity(0.8),
                strokeColor: Color.white,
                strokeGlow: Color.white.opacity(0.6),
                progressTrack: Color.white.opacity(0.15)
            )
        }
    }
}

// MARK: - UIKit Resolved Colors

/// UIKit-side resolved colors for use with CALayer and UIView styling.
struct LuminaResolvedUIColors {
    let bubbleFill: UIColor
    let bubbleShadow: UIColor
    let strokeColor: UIColor
    let strokeGlow: UIColor
    let progressTrack: UIColor

    static func resolve(mode: LuminaColorMode, isDarkMode: Bool) -> LuminaResolvedUIColors {
        let isDark: Bool
        switch mode {
        case .auto:
            isDark = isDarkMode
        case .light:
            isDark = false
        case .dark:
            isDark = true
        }

        if isDark {
            return LuminaResolvedUIColors(
                bubbleFill: UIColor(white: 0.9, alpha: 0.85),
                bubbleShadow: UIColor.systemBlue.withAlphaComponent(0.4),
                strokeColor: UIColor(white: 0.85, alpha: 1.0),
                strokeGlow: UIColor.systemBlue.withAlphaComponent(0.3),
                progressTrack: UIColor(white: 0.4, alpha: 0.2)
            )
        } else {
            return LuminaResolvedUIColors(
                bubbleFill: UIColor.white.withAlphaComponent(0.8),
                bubbleShadow: UIColor.white.withAlphaComponent(0.8),
                strokeColor: UIColor.white,
                strokeGlow: UIColor.white.withAlphaComponent(0.6),
                progressTrack: UIColor.white.withAlphaComponent(0.15)
            )
        }
    }
}
