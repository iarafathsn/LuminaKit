import SwiftUI

/// A `ViewModifier` that overlays a determinate progress indicator
/// along the border of the modified view's shape.
///
/// The border fills from 0% to 100% based on the `value` binding.
/// A glowing leading edge provides visual polish.
struct LuminaProgressModifier: ViewModifier {

    @Binding var value: CGFloat
    let shape: any Shape
    let colorMode: LuminaColorMode

    @Environment(\.colorScheme) private var colorScheme

    /// Stroke width for the progress border.
    private let lineWidth: CGFloat = 3

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    progressOverlay(in: geometry.size)
                }
                .allowsHitTesting(false)
            }
    }

    @ViewBuilder
    private func progressOverlay(in size: CGSize) -> some View {
        let rect = CGRect(origin: .zero, size: size)
        let path = resolvePath(in: rect)
        let colors = LuminaResolvedColors.resolve(mode: colorMode, colorScheme: colorScheme)
        let clampedValue = min(max(value, 0), 1)

        Canvas { context, canvasSize in
            let swiftPath = Path(path)

            // Track (background)
            let trackStroke = swiftPath
                .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            context.fill(trackStroke, with: .color(colors.progressTrack))

            // Filled progress
            if clampedValue > 0 {
                let filledPath = swiftPath
                    .trimmedPath(from: 0, to: clampedValue)
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))

                // Glow
                context.drawLayer { ctx in
                    ctx.addFilter(.blur(radius: lineWidth * 1.5))
                    ctx.fill(filledPath, with: .color(colors.strokeGlow))
                }

                // Main stroke
                context.fill(filledPath, with: .color(colors.strokeColor))

                // Leading edge glow (brighter dot at the head)
                let headPoint = PathPointCalculator.pointAtFraction(clampedValue, on: path)
                let dotSize = lineWidth * 2.5
                let dotRect = CGRect(
                    x: headPoint.x - dotSize / 2,
                    y: headPoint.y - dotSize / 2,
                    width: dotSize,
                    height: dotSize
                )
                context.drawLayer { ctx in
                    ctx.addFilter(.blur(radius: dotSize * 0.6))
                    ctx.fill(Path(ellipseIn: dotRect), with: .color(colors.strokeColor.opacity(0.7)))
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: clampedValue)
    }

    private func resolvePath(in rect: CGRect) -> CGPath {
        shape.path(in: rect).cgPath
    }
}
