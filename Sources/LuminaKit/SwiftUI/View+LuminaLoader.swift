import SwiftUI

// MARK: - Public View Extension

public extension View {

    /// Adds a LuminaKit loading indicator that animates a bubble along
    /// the border of this view.
    ///
    /// The library auto-detects the view's size and corner radius.
    /// Use this overload for rectangular/rounded-rect views.
    ///
    /// - Parameters:
    ///   - isAnimating: Binding that controls start/stop. Set to `true` to show,
    ///     `false` to hide.
    ///   - bubbleSize: Diameter of the bubble in points. Default is `10`.
    ///   - speed: Revolutions per second. Default is `0.5`.
    /// - Returns: A view with the lumina loader overlay.
    func luminaLoader(
        isAnimating: Binding<Bool>,
        bubbleSize: CGFloat = 10,
        speed: CGFloat = 0.5
    ) -> some View {
        let config = LuminaConfiguration(bubbleSize: bubbleSize, speed: speed)
        return modifier(
            LuminaLoaderModifier<RoundedRectangle>(
                isAnimating: isAnimating,
                shape: nil,
                configuration: config
            )
        )
    }

    /// Adds a LuminaKit loading indicator that animates a bubble along
    /// the border of the given shape.
    ///
    /// Use this overload when the view uses a non-rectangular clip shape
    /// (e.g., `Circle()`, `Capsule()`, or a custom `Shape`).
    ///
    /// - Parameters:
    ///   - isAnimating: Binding that controls start/stop. Set to `true` to show,
    ///     `false` to hide.
    ///   - shape: The shape whose path the bubble should follow.
    ///   - bubbleSize: Diameter of the bubble in points. Default is `10`.
    ///   - speed: Revolutions per second. Default is `0.5`.
    /// - Returns: A view with the lumina loader overlay.
    func luminaLoader<S: Shape>(
        isAnimating: Binding<Bool>,
        shape: S,
        bubbleSize: CGFloat = 10,
        speed: CGFloat = 0.5
    ) -> some View {
        let config = LuminaConfiguration(bubbleSize: bubbleSize, speed: speed)
        return modifier(
            LuminaLoaderModifier(
                isAnimating: isAnimating,
                shape: shape,
                configuration: config
            )
        )
    }
}
