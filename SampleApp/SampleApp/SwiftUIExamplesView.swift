import SwiftUI
import LuminaKit

struct SwiftUIExamplesView: View {

    @State private var isButtonLoading = false
    @State private var isCircleLoading = false
    @State private var isCapsuleLoading = false
    @State private var isCardLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    roundedRectExample
                    circleExample
                    capsuleExample
                    cardExample

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SwiftUI")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Tap any example to toggle the loader")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Rounded Rectangle (Auto-detect)

    private var roundedRectExample: some View {
        ExampleCard(title: "Rounded Rectangle", subtitle: "Auto-detects corner radius") {
            Button {
                isButtonLoading.toggle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: isButtonLoading ? "stop.fill" : "play.fill")
                    Text(isButtonLoading ? "Stop Loading" : "Start Loading")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .luminaLoader(isAnimating: $isButtonLoading)
        }
    }

    // MARK: - Circle

    private var circleExample: some View {
        ExampleCard(title: "Circle", subtitle: "Explicit shape: Circle()") {
            Button {
                isCircleLoading.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    Image(systemName: "person.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .luminaLoader(isAnimating: $isCircleLoading, shape: Circle())
        }
    }

    // MARK: - Capsule

    private var capsuleExample: some View {
        ExampleCard(title: "Capsule", subtitle: "Explicit shape: Capsule()") {
            Button {
                isCapsuleLoading.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Download")
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.green.gradient)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .luminaLoader(isAnimating: $isCapsuleLoading, shape: Capsule())
        }
    }

    // MARK: - Card

    private var cardExample: some View {
        ExampleCard(title: "Card View", subtitle: "Custom bubbleSize & speed") {
            Button {
                isCardLoading.toggle()
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundStyle(.secondary)
                    }
                    Text("Processing Document")
                        .font(.headline)
                    Text("Analyzing content and extracting metadata from the uploaded file.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .luminaLoader(
                isAnimating: $isCardLoading,
                shape: RoundedRectangle(cornerRadius: 16),
                bubbleSize: 12,
                speed: 0.35
            )
        }
    }
}

// MARK: - Example Card Container

private struct ExampleCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    SwiftUIExamplesView()
}
