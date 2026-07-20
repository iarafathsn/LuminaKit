import UIKit
import ObjectiveC

// MARK: - Associated Object Keys

private nonisolated(unsafe) var luminaLoaderKey: UInt8 = 0
private nonisolated(unsafe) var luminaProgressKey: UInt8 = 0

// MARK: - Indeterminate Loader

public extension UIView {

    /// Shows a LuminaKit loading indicator on this view.
    ///
    /// The loader animates along the border of this view's bounds,
    /// auto-detecting the corner radius from the layer.
    ///
    /// - Parameters:
    ///   - path: Optional custom `CGPath` for non-rectangular shapes.
    ///   - style: The loader style. Default is `.bubble`.
    ///   - bubbleSize: Diameter of the bubble (for `.bubble` style). Default is `10`.
    ///   - speed: Revolutions per second. Default is `0.5`.
    ///   - colorMode: Dark mode behavior. Default is `.auto`.
    func showLuminaLoader(
        path: CGPath? = nil,
        style: LuminaLoaderStyle = .bubble,
        bubbleSize: CGFloat = 10,
        speed: CGFloat = 0.5,
        colorMode: LuminaColorMode = .auto
    ) {
        // Remove existing loader if any
        hideLuminaLoader()

        let config = LuminaConfiguration(
            bubbleSize: bubbleSize,
            speed: speed,
            style: style,
            colorMode: colorMode
        )
        let loader = LuminaLoaderUIView(configuration: config, customPath: path)

        loader.frame = bounds
        loader.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(loader)

        objc_setAssociatedObject(
            self,
            &luminaLoaderKey,
            loader,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        loader.startAnimating()
    }

    /// Hides and removes the LuminaKit loading indicator from this view.
    func hideLuminaLoader() {
        guard let loader = objc_getAssociatedObject(self, &luminaLoaderKey) as? LuminaLoaderUIView else {
            return
        }

        loader.stopAnimating()
        loader.removeFromSuperview()

        objc_setAssociatedObject(
            self,
            &luminaLoaderKey,
            nil,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}

// MARK: - Determinate Progress

public extension UIView {

    /// Shows a LuminaKit progress indicator on this view.
    ///
    /// - Parameters:
    ///   - value: Initial progress value (0.0...1.0).
    ///   - path: Optional custom `CGPath` for non-rectangular shapes.
    ///   - colorMode: Dark mode behavior. Default is `.auto`.
    func showLuminaProgress(
        value: CGFloat = 0,
        path: CGPath? = nil,
        colorMode: LuminaColorMode = .auto
    ) {
        hideLuminaProgress()

        let progressView = LuminaProgressUIView(colorMode: colorMode, customPath: path)

        progressView.frame = bounds
        progressView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(progressView)

        objc_setAssociatedObject(
            self,
            &luminaProgressKey,
            progressView,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        progressView.updateProgress(value)
    }

    /// Updates the progress value on the existing progress indicator.
    /// - Parameter value: Progress from 0.0 to 1.0.
    func updateLuminaProgress(value: CGFloat) {
        guard let progressView = objc_getAssociatedObject(self, &luminaProgressKey) as? LuminaProgressUIView else {
            return
        }
        progressView.updateProgress(value)
    }

    /// Hides and removes the LuminaKit progress indicator from this view.
    func hideLuminaProgress() {
        guard let progressView = objc_getAssociatedObject(self, &luminaProgressKey) as? LuminaProgressUIView else {
            return
        }

        progressView.removeFromSuperview()

        objc_setAssociatedObject(
            self,
            &luminaProgressKey,
            nil,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}
