import CoreGraphics

/// The visual style of the LuminaKit loader animation.
public enum LuminaLoaderStyle: Sendable, Equatable {

    /// A glowing bubble that moves along the view's border.
    /// This is the original LuminaKit style.
    case bubble

    /// A glowing arc segment that rotates along the view's border.
    /// - Parameter lineWidth: The width of the arc stroke. Default is `3`.
    case ring(lineWidth: CGFloat = 3)

    /// A breathing glow effect on the entire border that pulses in and out.
    case pulse
}
