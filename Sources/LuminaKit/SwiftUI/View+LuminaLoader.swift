import SwiftUI

// MARK: - Indeterminate Loader (Bubble / Ring / Pulse)

public extension View {

    /// Adds a LuminaKit loading indicator that animates along
    /// the border of this view. Auto-detects size and corner radius.
    ///
    /// - Parameters:
    ///   - isAnimating: Binding that controls start/stop.
    ///   - style: The loader style. Default is `.bubble`.
    ///   - bubbleSize: Diameter of the bubble (for `.bubble` style). Default is `10`.
    ///   - speed: Revolutions per second. Default is `0.5`.
    ///   - colorMode: Dark mode behavior. Default is `.auto`.
    /// - Returns: A view with the lumina loader overlay.
    func luminaLoader(
        isAnimating: Binding<Bool>,
        style: LuminaLoaderStyle = .bubble,
        bubbleSize: CGFloat = 10,
        speed: CGFloat = 0.5,
        colorMode: LuminaColorMode = .auto
    ) -> some View {
        let config = LuminaConfiguration(
            bubbleSize: bubbleSize,
            speed: speed,
            style: style,
            colorMode: colorMode
        )
        return modifier(
            LuminaLoaderModifier<RoundedRectangle>(
                isAnimating: isAnimating,
                shape: nil,
                configuration: config
            )
        )
    }

    /// Adds a LuminaKit loading indicator that animates along
    /// the border of the given shape.
    ///
    /// Use this overload when the view uses a non-rectangular clip shape
    /// (e.g., `Circle()`, `Capsule()`, or a custom `Shape`).
    ///
    /// - Parameters:
    ///   - isAnimating: Binding that controls start/stop.
    ///   - shape: The shape whose path the bubble should follow.
    ///   - style: The loader style. Default is `.bubble`.
    ///   - bubbleSize: Diameter of the bubble (for `.bubble` style). Default is `10`.
    ///   - speed: Revolutions per second. Default is `0.5`.
    ///   - colorMode: Dark mode behavior. Default is `.auto`.
    /// - Returns: A view with the lumina loader overlay.
    func luminaLoader<S: Shape>(
        isAnimating: Binding<Bool>,
        shape: S,
        style: LuminaLoaderStyle = .bubble,
        bubbleSize: CGFloat = 10,
        speed: CGFloat = 0.5,
        colorMode: LuminaColorMode = .auto
    ) -> some View {
        let config = LuminaConfiguration(
            bubbleSize: bubbleSize,
            speed: speed,
            style: style,
            colorMode: colorMode
        )
        return modifier(
            LuminaLoaderModifier(
                isAnimating: isAnimating,
                shape: shape,
                configuration: config
            )
        )
    }
}

// MARK: - Determinate Progress

public extension View {

    /// Adds a LuminaKit progress indicator along the border of this view.
    /// Auto-detects size and corner radius.
    ///
    /// - Parameters:
    ///   - value: Binding to a progress value (0.0...1.0).
    ///   - colorMode: Dark mode behavior. Default is `.auto`.
    /// - Returns: A view with the lumina progress overlay.
    func luminaProgress(
        value: Binding<CGFloat>,
        colorMode: LuminaColorMode = .auto
    ) -> some View {
        modifier(
            LuminaProgressModifier<RoundedRectangle>(
                value: value,
                shape: nil,
                colorMode: colorMode
            )
        )
    }

    /// Adds a LuminaKit progress indicator along the border of the given shape.
    ///
    /// - Parameters:
    ///   - value: Binding to a progress value (0.0...1.0).
    ///   - shape: The shape whose path the progress should follow.
    ///   - colorMode: Dark mode behavior. Default is `.auto`.
    /// - Returns: A view with the lumina progress overlay.
    func luminaProgress<S: Shape>(
        value: Binding<CGFloat>,
        shape: S,
        colorMode: LuminaColorMode = .auto
    ) -> some View {
        modifier(
            LuminaProgressModifier(
                value: value,
                shape: shape,
                colorMode: colorMode
            )
        )
    }
}
