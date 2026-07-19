import Testing
import CoreGraphics
@testable import LuminaKit

@Suite("PathPointCalculator Tests")
struct PathPointCalculatorTests {

    // MARK: - Rectangle Path Tests

    @Test("Point at fraction 0 on a rectangle starts at the path origin")
    func pointAtStartOfRect() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let path = CGPath(rect: rect, transform: nil)
        let point = PathPointCalculator.pointAtFraction(0, on: path)

        // CGPath(rect:) starts at the origin (0, 0)
        #expect(abs(point.x - 0) < 1.0)
        #expect(abs(point.y - 0) < 1.0)
    }

    @Test("Points at different fractions are at different positions")
    func pointsAtDifferentFractionsAreDifferent() {
        let rect = CGRect(x: 0, y: 0, width: 200, height: 100)
        let path = CGPath(rect: rect, transform: nil)

        let p0 = PathPointCalculator.pointAtFraction(0.0, on: path)
        let p25 = PathPointCalculator.pointAtFraction(0.25, on: path)
        let p50 = PathPointCalculator.pointAtFraction(0.5, on: path)
        let p75 = PathPointCalculator.pointAtFraction(0.75, on: path)

        // All four points should be distinct
        #expect(p0 != p25)
        #expect(p25 != p50)
        #expect(p50 != p75)
    }

    @Test("Point at fraction 1.0 returns to near the start")
    func pointAtEndReturnsToStart() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let path = CGPath(rect: rect, transform: nil)

        let pStart = PathPointCalculator.pointAtFraction(0, on: path)
        let pEnd = PathPointCalculator.pointAtFraction(1.0, on: path)

        // Should be at or very near the same point (closed path)
        #expect(abs(pStart.x - pEnd.x) < 2.0)
        #expect(abs(pStart.y - pEnd.y) < 2.0)
    }

    // MARK: - Total Length Tests

    @Test("Total length of a rectangle is its perimeter")
    func rectPerimeter() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let path = CGPath(rect: rect, transform: nil)
        let length = PathPointCalculator.totalLength(of: path)

        // Perimeter = 2 * (100 + 50) = 300
        #expect(abs(length - 300) < 1.0)
    }

    @Test("Total length of a square is 4× side length")
    func squarePerimeter() {
        let rect = CGRect(x: 0, y: 0, width: 80, height: 80)
        let path = CGPath(rect: rect, transform: nil)
        let length = PathPointCalculator.totalLength(of: path)

        // Perimeter = 4 * 80 = 320
        #expect(abs(length - 320) < 1.0)
    }

    // MARK: - Circle/Ellipse Path Tests

    @Test("Total length of a circle is approximately 2πr")
    func circlePerimeter() {
        let radius: CGFloat = 50
        let rect = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        let path = CGPath(ellipseIn: rect, transform: nil)
        let length = PathPointCalculator.totalLength(of: path)

        let expectedPerimeter = 2 * CGFloat.pi * radius
        // Allow 2% tolerance for curve sampling approximation
        let tolerance = expectedPerimeter * 0.02
        #expect(abs(length - expectedPerimeter) < tolerance)
    }

    // MARK: - Edge Cases

    @Test("Empty path returns zero point")
    func emptyPathReturnsZero() {
        let path = CGMutablePath()
        let point = PathPointCalculator.pointAtFraction(0.5, on: path)

        #expect(point == .zero)
    }

    @Test("Empty path has zero length")
    func emptyPathHasZeroLength() {
        let path = CGMutablePath()
        let length = PathPointCalculator.totalLength(of: path)

        #expect(length == 0)
    }

    @Test("Clamping: fraction below 0 is treated as 0")
    func fractionBelowZeroClamped() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let path = CGPath(rect: rect, transform: nil)

        let pNeg = PathPointCalculator.pointAtFraction(-0.5, on: path)
        let pZero = PathPointCalculator.pointAtFraction(0.0, on: path)

        #expect(abs(pNeg.x - pZero.x) < 0.01)
        #expect(abs(pNeg.y - pZero.y) < 0.01)
    }

    @Test("Clamping: fraction above 1 is treated as 1")
    func fractionAboveOneClamped() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let path = CGPath(rect: rect, transform: nil)

        let pOver = PathPointCalculator.pointAtFraction(1.5, on: path)
        let pOne = PathPointCalculator.pointAtFraction(1.0, on: path)

        #expect(abs(pOver.x - pOne.x) < 0.01)
        #expect(abs(pOver.y - pOne.y) < 0.01)
    }

    // MARK: - Rounded Rectangle Tests

    @Test("Rounded rectangle length is less than sharp rectangle")
    func roundedRectShorterThanSharpRect() {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 50)
        let sharpPath = CGPath(rect: rect, transform: nil)
        let roundedPath = CGPath(
            roundedRect: rect,
            cornerWidth: 10,
            cornerHeight: 10,
            transform: nil
        )

        let sharpLength = PathPointCalculator.totalLength(of: sharpPath)
        let roundedLength = PathPointCalculator.totalLength(of: roundedPath)

        // Rounded corners cut the corners, so perimeter is slightly less
        #expect(roundedLength < sharpLength)
    }
}
