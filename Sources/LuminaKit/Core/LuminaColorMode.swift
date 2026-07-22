import SwiftUI
import UIKit

/// Defines custom colors for the loader animation and progress indicators.
public struct LuminaColors: Sendable {
    public var bubbleFill: Color
    public var bubbleShadow: Color
    public var strokeColor: Color
    public var strokeGlow: Color
    public var progressTrack: Color

    /// Convenience initializer using a primary color and optional custom glow/shadow/track colors.
    ///
    /// - Parameters:
    ///   - primary: Main color used for bubble fill and stroke.
    ///   - glow: Color for the stroke glow. Defaults to `primary.opacity(0.4)`.
    ///   - shadow: Color for the bubble shadow. Defaults to `primary.opacity(0.4)`.
    ///   - track: Color for the progress track. Defaults to `primary.opacity(0.15)`.
    public init(
        primary: Color,
        glow: Color? = nil,
        shadow: Color? = nil,
        track: Color? = nil
    ) {
        self.bubbleFill = primary
        self.strokeColor = primary
        self.strokeGlow = glow ?? primary.opacity(0.4)
        self.bubbleShadow = shadow ?? primary.opacity(0.4)
        self.progressTrack = track ?? primary.opacity(0.15)
    }

    /// Full initializer for granular control over every visual component.
    public init(
        bubbleFill: Color,
        bubbleShadow: Color,
        strokeColor: Color,
        strokeGlow: Color,
        progressTrack: Color
    ) {
        self.bubbleFill = bubbleFill
        self.bubbleShadow = bubbleShadow
        self.strokeColor = strokeColor
        self.strokeGlow = strokeGlow
        self.progressTrack = progressTrack
    }
}

/// Controls how the loader adapts its colors to light/dark mode or custom themes.
public enum LuminaColorMode: Sendable {

    /// Automatically follows the system's current appearance
    /// (`colorScheme` in SwiftUI, `traitCollection` in UIKit).
    case auto

    /// Forces light-mode colors (white glow). Use on light backgrounds.
    case light

    /// Forces dark-mode colors (soft blue-white glow). Use on dark backgrounds.
    case dark

    /// Uses custom colors for both light and dark modes.
    case custom(LuminaColors)

    /// Adaptive custom colors: uses `light` colors in light mode and `dark` colors in dark mode.
    case adaptive(light: LuminaColors, dark: LuminaColors)
}

// MARK: - Resolved Colors

/// Internal resolved color set used by all SwiftUI loader views.
struct LuminaResolvedColors {
    let bubbleFill: Color
    let bubbleShadow: Color
    let strokeColor: Color
    let strokeGlow: Color
    let progressTrack: Color

    /// Resolves colors based on the color mode and current color scheme.
    static func resolve(mode: LuminaColorMode, colorScheme: ColorScheme) -> LuminaResolvedColors {
        switch mode {
        case .auto:
            return colorScheme == .dark ? darkDefaults : lightDefaults
        case .light:
            return lightDefaults
        case .dark:
            return darkDefaults
        case .custom(let colors):
            return LuminaResolvedColors(
                bubbleFill: colors.bubbleFill,
                bubbleShadow: colors.bubbleShadow,
                strokeColor: colors.strokeColor,
                strokeGlow: colors.strokeGlow,
                progressTrack: colors.progressTrack
            )
        case .adaptive(let lightColors, let darkColors):
            let colors = colorScheme == .dark ? darkColors : lightColors
            return LuminaResolvedColors(
                bubbleFill: colors.bubbleFill,
                bubbleShadow: colors.bubbleShadow,
                strokeColor: colors.strokeColor,
                strokeGlow: colors.strokeGlow,
                progressTrack: colors.progressTrack
            )
        }
    }

    private static let darkDefaults = LuminaResolvedColors(
        bubbleFill: Color(white: 0.9).opacity(0.85),
        bubbleShadow: Color(.systemBlue).opacity(0.4),
        strokeColor: Color(white: 0.85),
        strokeGlow: Color(.systemBlue).opacity(0.3),
        progressTrack: Color(white: 0.4).opacity(0.2)
    )

    private static let lightDefaults = LuminaResolvedColors(
        bubbleFill: Color.white.opacity(0.8),
        bubbleShadow: Color.white.opacity(0.5),
        strokeColor: Color.white,
        strokeGlow: Color.white.opacity(0.6),
        progressTrack: Color.white.opacity(0.15)
    )
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
        switch mode {
        case .auto:
            return isDarkMode ? darkDefaults : lightDefaults
        case .light:
            return lightDefaults
        case .dark:
            return darkDefaults
        case .custom(let colors):
            return LuminaResolvedUIColors(
                bubbleFill: UIColor(colors.bubbleFill),
                bubbleShadow: UIColor(colors.bubbleShadow),
                strokeColor: UIColor(colors.strokeColor),
                strokeGlow: UIColor(colors.strokeGlow),
                progressTrack: UIColor(colors.progressTrack)
            )
        case .adaptive(let lightColors, let darkColors):
            let colors = isDarkMode ? darkColors : lightColors
            return LuminaResolvedUIColors(
                bubbleFill: UIColor(colors.bubbleFill),
                bubbleShadow: UIColor(colors.bubbleShadow),
                strokeColor: UIColor(colors.strokeColor),
                strokeGlow: UIColor(colors.strokeGlow),
                progressTrack: UIColor(colors.progressTrack)
            )
        }
    }

    private static let darkDefaults = LuminaResolvedUIColors(
        bubbleFill: UIColor(white: 0.9, alpha: 0.85),
        bubbleShadow: UIColor.systemBlue.withAlphaComponent(0.4),
        strokeColor: UIColor(white: 0.85, alpha: 1.0),
        strokeGlow: UIColor.systemBlue.withAlphaComponent(0.3),
        progressTrack: UIColor(white: 0.4, alpha: 0.2)
    )

    private static let lightDefaults = LuminaResolvedUIColors(
        bubbleFill: UIColor.white.withAlphaComponent(0.8),
        bubbleShadow: UIColor.white.withAlphaComponent(0.8),
        strokeColor: UIColor.white,
        strokeGlow: UIColor.white.withAlphaComponent(0.6),
        progressTrack: UIColor.white.withAlphaComponent(0.15)
    )
}
