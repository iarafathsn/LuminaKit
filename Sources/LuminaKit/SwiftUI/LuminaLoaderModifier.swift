import SwiftUI

/// A `ViewModifier` that overlays an animated bubble tracing
/// the border of the modified view's shape.
///
/// When `isAnimating` is `true`, the bubble appears and continuously
/// moves along the path. When `false`, the overlay is hidden.
struct LuminaLoaderModifier<S: Shape>: ViewModifier {

    @Binding var isAnimating: Bool
    let shape: S?
    let configuration: LuminaConfiguration

    @State private var detectedCornerRadius: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .background(
                CornerRadiusReader(cornerRadius: $detectedCornerRadius)
                    .allowsHitTesting(false)
            )
            .overlay {
                if isAnimating {
                    GeometryReader { geometry in
                        luminaOverlay(in: geometry.size)
                    }
                    .allowsHitTesting(false)
                }
            }
    }

    @ViewBuilder
    private func luminaOverlay(in size: CGSize) -> some View {
        let rect = CGRect(origin: .zero, size: size)
        let path = resolvePath(in: rect)

        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let fraction = elapsed * configuration.speed
            // Wrap to 0...1
            let t = fraction - floor(fraction)

            let position = PathPointCalculator.pointAtFraction(t, on: path)

            LuminaBubbleView(size: configuration.bubbleSize)
                .position(position)
        }
    }

    /// Resolves the animation path from either the user-provided shape
    /// or an auto-detected rounded rectangle.
    private func resolvePath(in rect: CGRect) -> CGPath {
        if let shape = shape {
            return shape.path(in: rect).cgPath
        }

        // Auto-detect: use RoundedRectangle with detected corner radius
        let cornerRadius = detectedCornerRadius
        return RoundedRectangle(cornerRadius: cornerRadius)
            .path(in: rect)
            .cgPath
    }
}
