import UIKit

/// A `UIView` subclass that renders an animated loader tracing the border
/// of its superview's shape. Supports bubble, ring, and pulse styles.
///
/// Usage:
/// ```swift
/// let loader = LuminaLoaderUIView()
/// myView.addSubview(loader)
/// loader.startAnimating()
/// ```
///
/// Or use the `UIView` extension methods for convenience:
/// ```swift
/// myView.showLuminaLoader()
/// myView.hideLuminaLoader()
/// ```
public final class LuminaLoaderUIView: UIView {

    // MARK: - Configuration

    /// Configuration for loader style, size, speed, and color mode.
    public var configuration: LuminaConfiguration

    /// Optional custom path. If `nil`, the path is auto-built from
    /// the superview's bounds and corner radius.
    public var customPath: CGPath?

    // MARK: - State

    /// Whether the animation is currently running.
    public private(set) var isAnimating: Bool = false

    // MARK: - Private

    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var currentPath: CGPath?

    // Bubble style
    private let bubbleView: UIView = UIView()

    // Ring style
    private let ringTrackLayer = CAShapeLayer()
    private let ringArcLayer = CAShapeLayer()
    private let ringGlowLayer = CAShapeLayer()

    // Pulse style
    private let pulseStrokeLayer = CAShapeLayer()
    private let pulseGlowLayer = CAShapeLayer()

    // MARK: - Init

    /// Creates a new LuminaLoaderUIView with the given configuration.
    /// - Parameters:
    ///   - configuration: Loader configuration. Defaults to `.default`.
    ///   - customPath: Optional custom `CGPath` for non-rectangular shapes.
    public init(
        configuration: LuminaConfiguration = .default,
        customPath: CGPath? = nil
    ) {
        self.configuration = configuration
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
        switch configuration.style {
        case .bubble:
            setupBubble()
        case .ring:
            setupRing()
        case .pulse:
            setupPulse()
        }
    }

    private func setupBubble() {
        let size = configuration.bubbleSize
        bubbleView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        bubbleView.layer.cornerRadius = size / 2
        bubbleView.clipsToBounds = false
        bubbleView.isHidden = true
        applyBubbleStyle()
        addSubview(bubbleView)
    }

    private func applyBubbleStyle() {
        let size = configuration.bubbleSize
        let colors = resolveColors()

        if #available(iOS 26, *) {
            bubbleView.backgroundColor = colors.bubbleFill
            let glassEffect = UIGlassEffect()
            let effectView = UIVisualEffectView(effect: glassEffect)
            effectView.frame = bubbleView.bounds
            effectView.layer.cornerRadius = size / 2
            effectView.clipsToBounds = true
            effectView.tag = 999
            bubbleView.addSubview(effectView)
        } else {
            bubbleView.backgroundColor = colors.bubbleFill
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = bubbleView.bounds
            blurView.layer.cornerRadius = size / 2
            blurView.clipsToBounds = true
            blurView.tag = 999
            bubbleView.addSubview(blurView)
        }

        bubbleView.layer.shadowColor = colors.bubbleShadow.cgColor
        bubbleView.layer.shadowOpacity = 0.8
        bubbleView.layer.shadowRadius = size * 0.4
        bubbleView.layer.shadowOffset = .zero
    }

    private func setupRing() {
        // Track
        ringTrackLayer.fillColor = nil
        ringTrackLayer.lineCap = .round
        ringTrackLayer.lineJoin = .round
        layer.addSublayer(ringTrackLayer)

        // Glow
        ringGlowLayer.fillColor = nil
        ringGlowLayer.lineCap = .round
        ringGlowLayer.lineJoin = .round
        layer.addSublayer(ringGlowLayer)

        // Arc
        ringArcLayer.fillColor = nil
        ringArcLayer.lineCap = .round
        ringArcLayer.lineJoin = .round
        layer.addSublayer(ringArcLayer)
    }

    private func setupPulse() {
        // Glow
        pulseGlowLayer.fillColor = nil
        pulseGlowLayer.lineCap = .round
        pulseGlowLayer.lineJoin = .round
        layer.addSublayer(pulseGlowLayer)

        // Stroke
        pulseStrokeLayer.fillColor = nil
        pulseStrokeLayer.lineCap = .round
        pulseStrokeLayer.lineJoin = .round
        layer.addSublayer(pulseStrokeLayer)
    }

    // MARK: - Color Resolution

    private func resolveColors() -> LuminaResolvedUIColors {
        let isDark = traitCollection.userInterfaceStyle == .dark
        return LuminaResolvedUIColors.resolve(mode: configuration.colorMode, isDarkMode: isDark)
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()

        if let effectView = bubbleView.viewWithTag(999) {
            effectView.frame = bubbleView.bounds
        }

        rebuildPath()
        updateLayerPaths()
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

        switch configuration.style {
        case .ring(let lineWidth):
            ringTrackLayer.path = path
            ringTrackLayer.lineWidth = lineWidth
            ringTrackLayer.strokeColor = colors.progressTrack.cgColor

            ringArcLayer.path = path
            ringArcLayer.lineWidth = lineWidth
            ringArcLayer.strokeColor = colors.strokeColor.cgColor

            ringGlowLayer.path = path
            ringGlowLayer.lineWidth = lineWidth
            ringGlowLayer.strokeColor = colors.strokeGlow.cgColor
            ringGlowLayer.shadowColor = colors.strokeGlow.cgColor
            ringGlowLayer.shadowRadius = lineWidth * 1.5
            ringGlowLayer.shadowOpacity = 1.0
            ringGlowLayer.shadowOffset = .zero

        case .pulse:
            let lineWidth: CGFloat = 2.5
            pulseStrokeLayer.path = path
            pulseStrokeLayer.lineWidth = lineWidth
            pulseStrokeLayer.strokeColor = colors.strokeColor.cgColor

            pulseGlowLayer.path = path
            pulseGlowLayer.lineWidth = lineWidth
            pulseGlowLayer.strokeColor = colors.strokeGlow.cgColor
            pulseGlowLayer.shadowColor = colors.strokeGlow.cgColor
            pulseGlowLayer.shadowOpacity = 1.0
            pulseGlowLayer.shadowOffset = .zero

        default:
            break
        }
    }

    private func updateColors() {
        let colors = resolveColors()

        switch configuration.style {
        case .bubble:
            bubbleView.layer.shadowColor = colors.bubbleShadow.cgColor
            bubbleView.backgroundColor = colors.bubbleFill

        case .ring(let lineWidth):
            ringTrackLayer.strokeColor = colors.progressTrack.cgColor
            ringArcLayer.strokeColor = colors.strokeColor.cgColor
            ringGlowLayer.strokeColor = colors.strokeGlow.cgColor
            ringGlowLayer.shadowColor = colors.strokeGlow.cgColor

        case .pulse:
            pulseStrokeLayer.strokeColor = colors.strokeColor.cgColor
            pulseGlowLayer.strokeColor = colors.strokeGlow.cgColor
            pulseGlowLayer.shadowColor = colors.strokeGlow.cgColor
        }
    }

    // MARK: - Animation Control

    /// Starts the loader animation.
    public func startAnimating() {
        guard !isAnimating else { return }

        isAnimating = true
        isHidden = false
        rebuildPath()
        updateLayerPaths()

        switch configuration.style {
        case .bubble:
            bubbleView.isHidden = false
        case .ring:
            ringTrackLayer.isHidden = false
            ringArcLayer.isHidden = false
            ringGlowLayer.isHidden = false
        case .pulse:
            pulseStrokeLayer.isHidden = false
            pulseGlowLayer.isHidden = false
        }

        startTime = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// Stops the loader animation and hides the view.
    public func stopAnimating() {
        guard isAnimating else { return }

        isAnimating = false
        displayLink?.invalidate()
        displayLink = nil
        isHidden = true

        switch configuration.style {
        case .bubble:
            bubbleView.isHidden = true
        case .ring:
            ringTrackLayer.isHidden = true
            ringArcLayer.isHidden = true
            ringGlowLayer.isHidden = true
        case .pulse:
            pulseStrokeLayer.isHidden = true
            pulseGlowLayer.isHidden = true
        }
    }

    // MARK: - Display Link Tick

    @objc private func tick() {
        guard let path = currentPath else { return }

        let elapsed = CACurrentMediaTime() - startTime

        switch configuration.style {
        case .bubble:
            tickBubble(elapsed: elapsed, path: path)
        case .ring:
            tickRing(elapsed: elapsed)
        case .pulse:
            tickPulse(elapsed: elapsed)
        }
    }

    private func tickBubble(elapsed: CFTimeInterval, path: CGPath) {
        let fraction = elapsed * Double(configuration.speed)
        let t = fraction - floor(fraction)
        let point = PathPointCalculator.pointAtFraction(t, on: path)
        let size = configuration.bubbleSize
        bubbleView.center = point
        if bubbleView.bounds.width != size {
            bubbleView.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            bubbleView.layer.cornerRadius = size / 2
        }
    }

    private func tickRing(elapsed: CFTimeInterval) {
        let fraction = elapsed * Double(configuration.speed)
        let t = fraction - floor(fraction)
        let arcLength: CGFloat = 0.15

        let start = t
        let end = t + arcLength

        if end <= 1.0 {
            ringArcLayer.strokeStart = start
            ringArcLayer.strokeEnd = end
            ringGlowLayer.strokeStart = start
            ringGlowLayer.strokeEnd = end
        } else {
            // For simplicity, clamp — the visual wrap is brief
            ringArcLayer.strokeStart = start
            ringArcLayer.strokeEnd = 1.0
            ringGlowLayer.strokeStart = start
            ringGlowLayer.strokeEnd = 1.0
        }
    }

    private func tickPulse(elapsed: CFTimeInterval) {
        let phase = sin(elapsed * Double(configuration.speed) * .pi * 2)
        let opacity = Float(0.15 + (1 + phase) * 0.425)
        let glowRadius = 1 + (1 + phase) * 3.5

        pulseStrokeLayer.opacity = opacity
        pulseGlowLayer.opacity = opacity
        pulseGlowLayer.shadowRadius = glowRadius
    }

    // MARK: - Cleanup

    deinit {
        // displayLink is invalidated in stopAnimating().
    }
}
