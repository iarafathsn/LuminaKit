import SwiftUI
import LuminaKit

struct SwiftUIExamplesView: View {

    @State private var isBubbleLoading = false
    @State private var isRingLoading = false
    @State private var isPulseLoading = false
    @State private var progress: CGFloat = 0.0
    @State private var progressTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    bubbleExample
                    ringExample
                    pulseExample
                    progressExample

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
        Text("Tap any example to toggle the loader")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    // MARK: - Bubble (Original)

    private var bubbleExample: some View {
        ExampleCard(title: "Bubble", subtitle: "Original style — .bubble") {
            Button {
                isBubbleLoading.toggle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: isBubbleLoading ? "stop.fill" : "play.fill")
                    Text(isBubbleLoading ? "Stop" : "Start Bubble")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .luminaLoader(isAnimating: $isBubbleLoading, style: .bubble)
        }
    }

    // MARK: - Ring

    private var ringExample: some View {
        ExampleCard(title: "Ring", subtitle: "Glowing arc — .ring(lineWidth: 3)") {
            Button {
                isRingLoading.toggle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: isRingLoading ? "stop.fill" : "play.fill")
                    Text(isRingLoading ? "Stop" : "Start Ring")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .luminaLoader(isAnimating: $isRingLoading, style: .ring(lineWidth: 3))
        }
    }

    // MARK: - Pulse

    private var pulseExample: some View {
        ExampleCard(title: "Pulse", subtitle: "Breathing glow — .pulse") {
            Button {
                isPulseLoading.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .luminaLoader(
                isAnimating: $isPulseLoading,
                shape: Circle(),
                style: .pulse,
                speed: 0.8
            )
        }
    }

    // MARK: - Progress

    private var progressExample: some View {
        ExampleCard(title: "Progress", subtitle: "Determinate — .luminaProgress(value:)") {
            VStack(spacing: 16) {
                // Progress target view
                HStack(spacing: 12) {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Downloading File")
                            .font(.subheadline.weight(.medium))
                        Text("\(Int(progress * 100))% complete")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(14)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .luminaProgress(value: $progress)

                // Controls
                HStack(spacing: 12) {
                    Button("Reset") {
                        stopProgressTimer()
                        progress = 0
                    }
                    .buttonStyle(.bordered)

                    Button("Simulate") {
                        simulateProgress()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(progressTask != nil)
                }
            }
        }
    }

    // MARK: - Progress Simulation

    private func simulateProgress() {
        progressTask?.cancel()
        progress = 0
        progressTask = Task {
            while progress < 1.0 {
                try? await Task.sleep(for: .milliseconds(50))
                guard !Task.isCancelled else { break }
                progress = min(progress + 0.01, 1.0)
            }
            progressTask = nil
        }
    }
    
    private func stopProgressTimer() {
        progressTask?.cancel()
        progressTask = nil
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
