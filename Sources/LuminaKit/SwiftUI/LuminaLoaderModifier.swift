import SwiftUI

/// A `ViewModifier` that overlays an animated loader tracing
/// the border of the modified view's shape.
///
/// Supports multiple styles: `.bubble`, `.ring`, and `.pulse`.
/// When `isAnimating` is `true`, the loader appears. When `false`, it hides.
struct LuminaLoaderModifier<S: Shape>: ViewModifier {

    @Binding var isAnimating: Bool
    let shape: S?
    let configuration: LuminaConfiguration

    @State private var detectedCornerRadius: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme

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
        let colors = LuminaResolvedColors.resolve(
            mode: configuration.colorMode,
            colorScheme: colorScheme
        )

        switch configuration.style {
        case .bubble:
            bubbleOverlay(path: path, colors: colors)

        case .ring(let lineWidth):
            LuminaRingView(
                path: path,
                lineWidth: lineWidth,
                speed: configuration.speed,
                colors: colors
            )

        case .pulse:
            LuminaPulseView(
                path: path,
                speed: configuration.speed,
                colors: colors
            )
        }
    }

    @ViewBuilder
    private func bubbleOverlay(path: CGPath, colors: LuminaResolvedColors) -> some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let fraction = elapsed * configuration.speed
            let t = fraction - floor(fraction)

            let position = PathPointCalculator.pointAtFraction(t, on: path)

            LuminaBubbleView(size: configuration.bubbleSize, colors: colors)
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
