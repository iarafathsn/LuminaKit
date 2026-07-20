import UIKit

/// A `UIView` subclass that renders a determinate progress indicator
/// along the border of its superview's shape.
///
/// Usage:
/// ```swift
/// let progress = LuminaProgressUIView()
/// myView.addSubview(progress)
/// progress.updateProgress(0.5) // 50%
/// ```
public final class LuminaProgressUIView: UIView {

    // MARK: - Configuration

    /// How the progress adapts its colors to light/dark mode.
    public var colorMode: LuminaColorMode

    /// Optional custom path. If `nil`, auto-built from superview.
    public var customPath: CGPath?

    // MARK: - Private

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let glowLayer = CAShapeLayer()
    private let headDotLayer = CALayer()

    private let lineWidth: CGFloat = 3
    private var currentPath: CGPath?
    private var currentValue: CGFloat = 0

    // MARK: - Init

    public init(
        colorMode: LuminaColorMode = .auto,
        customPath: CGPath? = nil
    ) {
        self.colorMode = colorMode
        self.customPath = customPath

        super.init(frame: .zero)

        isUserInteractionEnabled = false
        backgroundColor = .clear
        clipsToBounds = false

        setupLayers()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - Setup

    private func setupLayers() {
        // Track
        trackLayer.fillColor = nil
        trackLayer.lineCap = .round
        trackLayer.lineJoin = .round
        trackLayer.lineWidth = lineWidth
        layer.addSublayer(trackLayer)

        // Glow
        glowLayer.fillColor = nil
        glowLayer.lineCap = .round
        glowLayer.lineJoin = .round
        glowLayer.lineWidth = lineWidth
        glowLayer.shadowOffset = .zero
        glowLayer.shadowOpacity = 1.0
        layer.addSublayer(glowLayer)

        // Progress
        progressLayer.fillColor = nil
        progressLayer.lineCap = .round
        progressLayer.lineJoin = .round
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)

        // Head dot
        let dotSize = lineWidth * 2.5
        headDotLayer.frame = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
        headDotLayer.cornerRadius = dotSize / 2
        headDotLayer.shadowOffset = .zero
        headDotLayer.shadowOpacity = 0.7
        headDotLayer.shadowRadius = dotSize * 0.6
        headDotLayer.isHidden = true
        layer.addSublayer(headDotLayer)
    }

    // MARK: - Color Resolution

    private func resolveColors() -> LuminaResolvedUIColors {
        let isDark = traitCollection.userInterfaceStyle == .dark
        return LuminaResolvedUIColors.resolve(mode: colorMode, isDarkMode: isDark)
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        rebuildPath()
        updateLayerPaths()
        updateHeadPosition()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateColors()
        }
    }

    private func rebuildPath() {
        if let custom = customPath {
            currentPath = custom
        } else if let superview = superview {
            let rect = superview.bounds
            let cornerRadius = superview.layer.cornerRadius
            currentPath = UIBezierPath(
                roundedRect: rect,
                cornerRadius: cornerRadius
            ).cgPath
        }
    }

    private func updateLayerPaths() {
        guard let path = currentPath else { return }
        let colors = resolveColors()

        trackLayer.path = path
        trackLayer.strokeColor = colors.progressTrack.cgColor

        progressLayer.path = path
        progressLayer.strokeColor = colors.strokeColor.cgColor

        glowLayer.path = path
        glowLayer.strokeColor = colors.strokeGlow.cgColor
        glowLayer.shadowColor = colors.strokeGlow.cgColor
        glowLayer.shadowRadius = lineWidth * 1.5

        headDotLayer.backgroundColor = colors.strokeColor.cgColor
        headDotLayer.shadowColor = colors.strokeColor.cgColor
    }

    private func updateColors() {
        let colors = resolveColors()
        trackLayer.strokeColor = colors.progressTrack.cgColor
        progressLayer.strokeColor = colors.strokeColor.cgColor
        glowLayer.strokeColor = colors.strokeGlow.cgColor
        glowLayer.shadowColor = colors.strokeGlow.cgColor
        headDotLayer.backgroundColor = colors.strokeColor.cgColor
        headDotLayer.shadowColor = colors.strokeColor.cgColor
    }

    // MARK: - Public API

    /// Updates the progress value with smooth animation.
    /// - Parameter value: Progress from 0.0 to 1.0.
    public func updateProgress(_ value: CGFloat) {
        let clamped = min(max(value, 0), 1)
        currentValue = clamped

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))

        progressLayer.strokeEnd = clamped
        glowLayer.strokeEnd = clamped

        CATransaction.commit()

        headDotLayer.isHidden = clamped <= 0
        updateHeadPosition()
    }

    private func updateHeadPosition() {
        guard let path = currentPath, currentValue > 0 else {
            headDotLayer.isHidden = true
            return
        }

        let point = PathPointCalculator.pointAtFraction(currentValue, on: path)
        headDotLayer.position = point
        headDotLayer.isHidden = false
    }
}
