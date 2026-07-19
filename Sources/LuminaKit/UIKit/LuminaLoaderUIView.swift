import UIKit

/// A `UIView` subclass that renders an animated bubble tracing the border
/// of its superview's shape.
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

    /// Configuration for bubble size and speed.
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
    private let bubbleView: UIView
    private var currentPath: CGPath?

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
        self.bubbleView = UIView()

        super.init(frame: .zero)

        setupBubble()
        isUserInteractionEnabled = false
        backgroundColor = .clear
        clipsToBounds = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - Bubble Setup

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

        if #available(iOS 26, *) {
            // Liquid Glass style
            bubbleView.backgroundColor = UIColor.white.withAlphaComponent(0.5)

            // Use UIGlassEffect for the liquid glass look
            let glassEffect = UIGlassEffect()
            let effectView = UIVisualEffectView(effect: glassEffect)
            effectView.frame = bubbleView.bounds
            effectView.layer.cornerRadius = size / 2
            effectView.clipsToBounds = true
            effectView.tag = 999 // Tag for identification
            bubbleView.addSubview(effectView)
        } else {
            // Fallback: semi-translucent white with blur
            bubbleView.backgroundColor = UIColor.white.withAlphaComponent(0.8)

            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = bubbleView.bounds
            blurView.layer.cornerRadius = size / 2
            blurView.clipsToBounds = true
            blurView.tag = 999
            bubbleView.addSubview(blurView)
        }

        // Shadow for glow
        bubbleView.layer.shadowColor = UIColor.white.cgColor
        bubbleView.layer.shadowOpacity = 0.8
        bubbleView.layer.shadowRadius = size * 0.4
        bubbleView.layer.shadowOffset = .zero
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()

        // Update the effect view frame if bubble size changed
        if let effectView = bubbleView.viewWithTag(999) {
            effectView.frame = bubbleView.bounds
        }

        // Rebuild path on layout changes
        rebuildPath()
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

    // MARK: - Animation Control

    /// Starts the bubble animation.
    public func startAnimating() {
        guard !isAnimating else { return }

        isAnimating = true
        bubbleView.isHidden = false
        isHidden = false

        rebuildPath()

        startTime = CACurrentMediaTime()
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// Stops the bubble animation and hides the view.
    public func stopAnimating() {
        guard isAnimating else { return }

        isAnimating = false
        displayLink?.invalidate()
        displayLink = nil
        bubbleView.isHidden = true
        isHidden = true
    }

    // MARK: - Display Link Tick

    @objc private func tick() {
        guard let path = currentPath else { return }

        let elapsed = CACurrentMediaTime() - startTime
        let fraction = elapsed * Double(configuration.speed)
        let t = fraction - floor(fraction)

        let point = PathPointCalculator.pointAtFraction(t, on: path)

        let size = configuration.bubbleSize
        bubbleView.center = point

        // Ensure bubble size is correct
        if bubbleView.bounds.width != size {
            bubbleView.bounds = CGRect(x: 0, y: 0, width: size, height: size)
            bubbleView.layer.cornerRadius = size / 2
        }
    }

    // MARK: - Cleanup

    deinit {
        // displayLink is invalidated in stopAnimating().
        // No additional cleanup needed here.
    }
}
