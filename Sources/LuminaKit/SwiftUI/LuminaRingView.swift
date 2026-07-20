import SwiftUI

/// A glowing arc segment that rotates along the view's border path.
///
/// The ring is drawn as a trimmed stroke on the resolved `CGPath`,
/// covering ~15% of the total perimeter, creating a comet-like effect.
struct LuminaRingView: View {

    let path: CGPath
    let lineWidth: CGFloat
    let speed: CGFloat
    let colors: LuminaResolvedColors

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let fraction = elapsed * speed
            let t = fraction - fraction.rounded(.down)

            Canvas { context, size in
                let swiftPath = Path(path)
                let trimStart = t
                let trimLength: CGFloat = 0.15
                let trimEnd = trimStart + trimLength

                // Draw track (subtle background stroke)
                var trackPath = swiftPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                context.fill(trackPath, with: .color(colors.progressTrack))

                // Draw the arc segment — handle wrap-around
                if trimEnd <= 1.0 {
                    let arcPath = swiftPath
                        .trimmedPath(from: trimStart, to: trimEnd)
                        .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    // Glow layer
                    context.drawLayer { ctx in
                        ctx.addFilter(.blur(radius: lineWidth * 1.5))
                        ctx.fill(arcPath, with: .color(colors.strokeGlow))
                    }
                    // Main stroke
                    context.fill(arcPath, with: .color(colors.strokeColor))
                } else {
                    // Wrap around: draw two segments
                    let part1 = swiftPath
                        .trimmedPath(from: trimStart, to: 1.0)
                        .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    let part2 = swiftPath
                        .trimmedPath(from: 0.0, to: trimEnd - 1.0)
                        .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))

                    // Glow layer
                    context.drawLayer { ctx in
                        ctx.addFilter(.blur(radius: lineWidth * 1.5))
                        ctx.fill(part1, with: .color(colors.strokeGlow))
                        ctx.fill(part2, with: .color(colors.strokeGlow))
                    }
                    // Main stroke
                    context.fill(part1, with: .color(colors.strokeColor))
                    context.fill(part2, with: .color(colors.strokeColor))
                }
            }
        }
    }
}
