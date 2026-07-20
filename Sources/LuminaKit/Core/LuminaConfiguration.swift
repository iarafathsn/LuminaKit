import CoreGraphics

/// Configuration for the LuminaKit loader appearance and behavior.
public struct LuminaConfiguration: Sendable {

    /// The diameter of the animated bubble, in points.
    /// Applies to `.bubble` style. For `.ring`, use `style: .ring(lineWidth:)`.
    public var bubbleSize: CGFloat

    /// Animation speed: number of full revolutions per second.
    public var speed: CGFloat

    /// The visual style of the loader animation.
    public var style: LuminaLoaderStyle

    /// How the loader adapts its colors to light/dark mode.
    public var colorMode: LuminaColorMode

    /// Default configuration with sensible values.
    public static let `default` = LuminaConfiguration(
        bubbleSize: 10,
        speed: 0.5,
        style: .bubble,
        colorMode: .auto
    )

    /// Creates a custom configuration.
    /// - Parameters:
    ///   - bubbleSize: Diameter of the bubble in points. Default is `10`.
    ///   - speed: Revolutions per second. Default is `0.5`.
    ///   - style: The visual loader style. Default is `.bubble`.
    ///   - colorMode: Dark mode behavior. Default is `.auto`.
    public init(
        bubbleSize: CGFloat = 10,
        speed: CGFloat = 0.5,
        style: LuminaLoaderStyle = .bubble,
        colorMode: LuminaColorMode = .auto
    ) {
        self.bubbleSize = bubbleSize
        self.speed = speed
        self.style = style
        self.colorMode = colorMode
    }
}
