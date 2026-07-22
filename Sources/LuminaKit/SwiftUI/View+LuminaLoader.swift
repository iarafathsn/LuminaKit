import SwiftUI

// MARK: - Indeterminate Loader (Bubble / Ring / Pulse)

public extension View {

    /// Adds a LuminaKit loading indicator that animates along
    /// the border of the given shape.
    ///
    /// - Parameters:
    ///   - isAnimating: Binding that controls start/stop.
    ///   - shape: The shape whose path the loader should follow. Default is `Rectangle()`.
    ///   - style: The loader style. Default is `.bubble`.
    ///   - bubbleSize: Diameter of the bubble (for `.bubble` style). Default is `10`.
    ///   - speed: Revolutions per second. Default is `0.5`.
    ///   - colorMode: Dark mode behavior. Default is `.auto`.
    /// - Returns: A view with the lumina loader overlay.
    func luminaLoader(
        isAnimating: Binding<Bool>,
        shape: any Shape = Rectangle(),
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

    /// Adds a LuminaKit progress indicator along the border of the given shape.
    ///
    /// - Parameters:
    ///   - value: Binding to a progress value (0.0...1.0).
    ///   - shape: The shape whose path the progress should follow. Default is `Rectangle()`.
    ///   - colorMode: Dark mode behavior. Default is `.auto`.
    /// - Returns: A view with the lumina progress overlay.
    func luminaProgress(
        value: Binding<CGFloat>,
        shape: any Shape = Rectangle(),
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
