import SwiftUI

/// A breathing glow effect on the entire border that pulses in and out.
///
/// The full border stroke is drawn and its opacity/glow radius oscillates
/// using a sine wave for a smooth, rhythmic breathing animation.
struct LuminaPulseView: View {

    let path: CGPath
    let speed: CGFloat
    let colors: LuminaResolvedColors

    /// Stroke width for the pulse border.
    private let lineWidth: CGFloat = 2.5

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            // Sine wave for smooth breathing: speed controls cycles per second
            let phase = sin(elapsed * speed * .pi * 2)
            // Map sine [-1, 1] to [0.15, 1.0]
            let opacity = 0.15 + (1 + phase) * 0.425
            // Map sine to glow radius [1, 8]
            let glowRadius = 1 + (1 + phase) * 3.5

            Canvas { context, size in
                let swiftPath = Path(path)
                let strokedPath = swiftPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))

                // Glow layer
                context.drawLayer { ctx in
                    ctx.addFilter(.blur(radius: glowRadius))
                    ctx.fill(strokedPath, with: .color(colors.strokeGlow.opacity(opacity)))
                }

                // Main stroke
                context.fill(strokedPath, with: .color(colors.strokeColor.opacity(opacity)))
            }
        }
    }
}
