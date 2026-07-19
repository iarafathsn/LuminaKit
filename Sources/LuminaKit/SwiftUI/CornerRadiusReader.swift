import SwiftUI

/// A small `UIViewRepresentable` that reads the corner radius from the
/// nearest UIKit backing layer and reports it back via a binding.
///
/// This is placed as a `.background` on the target view so it can
/// introspect the UIKit layer without affecting layout.
struct CornerRadiusReader: UIViewRepresentable {

    @Binding var cornerRadius: CGFloat

    func makeUIView(context: Context) -> CornerRadiusIntrospectionView {
        let view = CornerRadiusIntrospectionView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        view.onCornerRadiusDetected = { radius in
            DispatchQueue.main.async {
                if self.cornerRadius != radius {
                    self.cornerRadius = radius
                }
            }
        }
        return view
    }

    func updateUIView(_ uiView: CornerRadiusIntrospectionView, context: Context) {
        // Re-check on each SwiftUI update cycle
        uiView.detectCornerRadius()
    }
}

/// A UIView that walks up the view hierarchy to find the nearest
/// non-zero corner radius.
final class CornerRadiusIntrospectionView: UIView {

    var onCornerRadiusDetected: ((CGFloat) -> Void)?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        detectCornerRadius()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        detectCornerRadius()
    }

    func detectCornerRadius() {
        // Walk up the superview chain to find a non-zero corner radius.
        // The immediate superview is often a SwiftUI hosting container,
        // so we check a few levels up.
        var current: UIView? = superview
        var depth = 0
        let maxDepth = 5

        while let view = current, depth < maxDepth {
            if view.layer.cornerRadius > 0 {
                onCornerRadiusDetected?(view.layer.cornerRadius)
                return
            }
            current = view.superview
            depth += 1
        }

        // No corner radius found — default to 0
        onCornerRadiusDetected?(0)
    }
}
