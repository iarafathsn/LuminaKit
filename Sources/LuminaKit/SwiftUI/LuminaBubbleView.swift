import SwiftUI

/// The animated bubble view that renders differently based on iOS version:
/// - iOS 26+: Uses Apple's Liquid Glass material
/// - iOS 18–25: Uses ultraThinMaterial + white glow + shadow
struct LuminaBubbleView: View {

    let size: CGFloat

    var body: some View {
        if #available(iOS 26, *) {
            liquidGlassBubble
        } else {
            fallbackBubble
        }
    }

    // MARK: - iOS 26+ Liquid Glass

    @available(iOS 26, *)
    private var liquidGlassBubble: some View {
        Circle()
            .fill(.white.opacity(0.5))
            .frame(width: size, height: size)
            .glassEffect(.regular.interactive())
            .shadow(color: .white.opacity(0.6), radius: size * 0.4)
    }

    // MARK: - iOS 18–25 Fallback

    private var fallbackBubble: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .overlay(
                Circle()
                    .fill(.white.opacity(0.8))
            )
            .overlay(
                Circle()
                    .stroke(.white.opacity(0.6), lineWidth: 0.5)
            )
            .frame(width: size, height: size)
            .shadow(color: .white.opacity(0.8), radius: size * 0.4)
    }
}
