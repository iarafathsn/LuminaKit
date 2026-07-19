import UIKit
import ObjectiveC

// MARK: - Associated Object Key

private nonisolated(unsafe) var luminaLoaderKey: UInt8 = 0

// MARK: - UIView Extension

public extension UIView {

    /// Shows a LuminaKit loading indicator on this view.
    ///
    /// The bubble animates along the border of this view's bounds,
    /// auto-detecting the corner radius from the layer.
    ///
    /// - Parameters:
    ///   - path: Optional custom `CGPath` for non-rectangular shapes.
    ///     If `nil`, the path is auto-built from this view's bounds and corner radius.
    ///   - bubbleSize: Diameter of the bubble in points. Default is `10`.
    ///   - speed: Revolutions per second. Default is `0.5`.
    func showLuminaLoader(
        path: CGPath? = nil,
        bubbleSize: CGFloat = 10,
        speed: CGFloat = 0.5
    ) {
        // Remove existing loader if any
        hideLuminaLoader()

        let config = LuminaConfiguration(bubbleSize: bubbleSize, speed: speed)
        let loader = LuminaLoaderUIView(configuration: config, customPath: path)

        loader.frame = bounds
        loader.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(loader)

        // Store reference via associated object
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
