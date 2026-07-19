import CoreGraphics

/// Computes points along any `CGPath` perimeter at a given fraction (0...1).
///
/// This is the core engine that enables shape-agnostic animation — it decomposes
/// a path into line/curve segments, measures total length, and returns exact
/// positions at any fraction of the perimeter.
public struct PathPointCalculator {

    // MARK: - Segment Model

    /// A single segment of the decomposed path.
    enum Segment {
        case line(from: CGPoint, to: CGPoint)
        case quadCurve(from: CGPoint, control: CGPoint, to: CGPoint)
        case cubicCurve(from: CGPoint, control1: CGPoint, control2: CGPoint, to: CGPoint)
    }

    // MARK: - Public API

    /// Returns the point at fraction `t` (0...1) along the given path's perimeter.
    /// - Parameters:
    ///   - t: A value from 0 to 1 representing the fraction along the path.
    ///   - path: The `CGPath` to traverse.
    /// - Returns: The `CGPoint` at the given fraction, or `.zero` if the path is empty.
    public static func pointAtFraction(_ t: CGFloat, on path: CGPath) -> CGPoint {
        let segments = decompose(path: path)
        guard !segments.isEmpty else { return .zero }

        let lengths = segments.map { length(of: $0) }
        let totalLength = lengths.reduce(0, +)
        guard totalLength > 0 else { return .zero }

        let clampedT = min(max(t, 0), 1)
        let targetDistance = clampedT * totalLength

        var accumulated: CGFloat = 0
        for (i, segment) in segments.enumerated() {
            let segLen = lengths[i]
            if accumulated + segLen >= targetDistance {
                let localT = segLen > 0 ? (targetDistance - accumulated) / segLen : 0
                return point(on: segment, at: localT)
            }
            accumulated += segLen
        }

        // Edge case: return last point
        if let last = segments.last {
            return point(on: last, at: 1.0)
        }
        return .zero
    }

    /// Computes the total perimeter length of the given path.
    /// - Parameter path: The `CGPath` to measure.
    /// - Returns: The total length in points.
    public static func totalLength(of path: CGPath) -> CGFloat {
        let segments = decompose(path: path)
        return segments.map { length(of: $0) }.reduce(0, +)
    }

    // MARK: - Path Decomposition

    /// Decomposes a `CGPath` into discrete segments.
    static func decompose(path: CGPath) -> [Segment] {
        var segments: [Segment] = []
        var currentPoint: CGPoint = .zero
        var subpathStart: CGPoint = .zero

        path.applyWithBlock { elementPointer in
            let element = elementPointer.pointee
            switch element.type {
            case .moveToPoint:
                currentPoint = element.points[0]
                subpathStart = currentPoint

            case .addLineToPoint:
                let to = element.points[0]
                segments.append(.line(from: currentPoint, to: to))
                currentPoint = to

            case .addQuadCurveToPoint:
                let control = element.points[0]
                let to = element.points[1]
                segments.append(.quadCurve(from: currentPoint, control: control, to: to))
                currentPoint = to

            case .addCurveToPoint:
                let control1 = element.points[0]
                let control2 = element.points[1]
                let to = element.points[2]
                segments.append(.cubicCurve(from: currentPoint, control1: control1, control2: control2, to: to))
                currentPoint = to

            case .closeSubpath:
                if currentPoint != subpathStart {
                    segments.append(.line(from: currentPoint, to: subpathStart))
                }
                currentPoint = subpathStart

            @unknown default:
                break
            }
        }

        return segments
    }

    // MARK: - Segment Length

    /// Sampling resolution for curve length approximation.
    private static let curveSampleCount = 64

    /// Computes the approximate length of a single segment.
    static func length(of segment: Segment) -> CGFloat {
        switch segment {
        case .line(let from, let to):
            return distance(from, to)

        case .quadCurve, .cubicCurve:
            var totalLength: CGFloat = 0
            var previous = point(on: segment, at: 0)
            for i in 1...curveSampleCount {
                let t = CGFloat(i) / CGFloat(curveSampleCount)
                let current = point(on: segment, at: t)
                totalLength += distance(previous, current)
                previous = current
            }
            return totalLength
        }
    }

    // MARK: - Point on Segment

    /// Returns the point on the given segment at local fraction `t` (0...1).
    static func point(on segment: Segment, at t: CGFloat) -> CGPoint {
        switch segment {
        case .line(let from, let to):
            return CGPoint(
                x: from.x + (to.x - from.x) * t,
                y: from.y + (to.y - from.y) * t
            )

        case .quadCurve(let from, let control, let to):
            let oneMinusT = 1 - t
            let a = oneMinusT * oneMinusT
            let b = 2 * oneMinusT * t
            let c = t * t
            return CGPoint(
                x: a * from.x + b * control.x + c * to.x,
                y: a * from.y + b * control.y + c * to.y
            )

        case .cubicCurve(let from, let control1, let control2, let to):
            let oneMinusT = 1 - t
            let a = oneMinusT * oneMinusT * oneMinusT
            let b = 3 * oneMinusT * oneMinusT * t
            let c = 3 * oneMinusT * t * t
            let d = t * t * t
            return CGPoint(
                x: a * from.x + b * control1.x + c * control2.x + d * to.x,
                y: a * from.y + b * control1.y + c * control2.y + d * to.y
            )
        }
    }

    // MARK: - Helpers

    private static func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        return sqrt(dx * dx + dy * dy)
    }
}
