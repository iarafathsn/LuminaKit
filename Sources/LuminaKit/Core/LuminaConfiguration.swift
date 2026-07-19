import CoreGraphics

/// Configuration for the LuminaKit loader appearance and behavior.
public struct LuminaConfiguration: Sendable {

    /// The diameter of the animated bubble, in points.
    public var bubbleSize: CGFloat

    /// Animation speed: number of full revolutions per second.
    public var speed: CGFloat

    /// Default configuration with sensible values.
    public static let `default` = LuminaConfiguration(
        bubbleSize: 10,
        speed: 0.5
    )

    /// Creates a custom configuration.
    /// - Parameters:
    ///   - bubbleSize: Diameter of the bubble in points. Default is `10`.
    ///   - speed: Revolutions per second. Default is `0.5`.
    public init(
        bubbleSize: CGFloat = 10,
        speed: CGFloat = 0.5
    ) {
        self.bubbleSize = bubbleSize
        self.speed = speed
    }
}
