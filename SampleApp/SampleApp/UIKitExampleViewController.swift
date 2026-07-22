import SwiftUI
import UIKit
import LuminaKit

// MARK: - SwiftUI Wrapper

struct UIKitExampleWrapperView: View {
    var body: some View {
        NavigationStack {
            UIKitExampleRepresentable()
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("UIKit")
        }
    }
}

// MARK: - UIViewControllerRepresentable

struct UIKitExampleRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIKitExampleViewController {
        UIKitExampleViewController()
    }

    func updateUIViewController(_ uiViewController: UIKitExampleViewController, context: Context) {}
}

// MARK: - UIKit View Controller

final class UIKitExampleViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    // Example views
    private let bubbleButton = UIButton(type: .system)
    private let ringButton = UIButton(type: .system)
    private let pulseView = UIView()
    private let progressButton = UIButton(type: .system)
    private let resetButton = UIButton(type: .system)
    private let progressLabel = UILabel()

    // State
    private var isBubbleLoading = false
    private var isRingLoading = false
    private var isPulseLoading = false
    private var currentProgress: CGFloat = 0
    private var progressTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupScrollView()
        setupExamples()
    }

    // MARK: - Layout

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
        ])
    }

    private func setupExamples() {
        let infoLabel = UILabel()
        infoLabel.text = "Tap any example to toggle the loader"
        infoLabel.font = .preferredFont(forTextStyle: .subheadline)
        infoLabel.textColor = .secondaryLabel
        infoLabel.textAlignment = .center
        stackView.addArrangedSubview(infoLabel)

        // 1. Bubble
        stackView.addArrangedSubview(
            makeExampleSection(
                title: "Bubble",
                subtitle: "showLuminaLoader(style: .bubble)",
                contentView: makeBubbleButton()
            )
        )

        // 2. Ring
        stackView.addArrangedSubview(
            makeExampleSection(
                title: "Ring",
                subtitle: "showLuminaLoader(style: .ring())",
                contentView: makeRingButton()
            )
        )

        // 3. Pulse
        stackView.addArrangedSubview(
            makeExampleSection(
                title: "Pulse",
                subtitle: "showLuminaLoader(style: .pulse)",
                contentView: makePulseView()
            )
        )

        // 4. Progress
        stackView.addArrangedSubview(
            makeExampleSection(
                title: "Progress",
                subtitle: "showLuminaProgress / updateLuminaProgress",
                contentView: makeProgressViewSection()
            )
        )
    }

    // MARK: - Example Builders

    private func makeBubbleButton() -> UIView {
        var config = UIButton.Configuration.filled()
        config.title = "Start Bubble"
        config.image = UIImage(systemName: "play.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium
        bubbleButton.configuration = config
        bubbleButton.layer.cornerRadius = 12
        bubbleButton.clipsToBounds = true
        bubbleButton.addTarget(self, action: #selector(toggleBubble), for: .touchUpInside)
        bubbleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return bubbleButton
    }

    private func makeRingButton() -> UIView {
        var config = UIButton.Configuration.filled()
        config.title = "Start Ring"
        config.image = UIImage(systemName: "play.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = .systemPurple
        config.cornerStyle = .medium
        ringButton.configuration = config
        ringButton.layer.cornerRadius = 12
        ringButton.clipsToBounds = true
        ringButton.addTarget(self, action: #selector(toggleRing), for: .touchUpInside)
        ringButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return ringButton
    }

    private func makePulseView() -> UIView {
        let container = UIView()
        let size: CGFloat = 80

        pulseView.backgroundColor = .systemOrange
        pulseView.layer.cornerRadius = size / 2
        pulseView.clipsToBounds = true
        pulseView.translatesAutoresizingMaskIntoConstraints = false
        pulseView.isUserInteractionEnabled = true

        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        pulseView.addSubview(imageView)

        container.addSubview(pulseView)

        NSLayoutConstraint.activate([
            pulseView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            pulseView.topAnchor.constraint(equalTo: container.topAnchor),
            pulseView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            pulseView.widthAnchor.constraint(equalToConstant: size),
            pulseView.heightAnchor.constraint(equalToConstant: size),

            imageView.centerXAnchor.constraint(equalTo: pulseView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: pulseView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 28),
            imageView.heightAnchor.constraint(equalToConstant: 28),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(togglePulse))
        pulseView.addGestureRecognizer(tap)

        return container
    }

    private func makeProgressViewSection() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 16

        // Progress target view
        let progressTarget = UIView()
        progressTarget.backgroundColor = .tertiarySystemGroupedBackground
        progressTarget.layer.cornerRadius = 12
        progressTarget.tag = 888

        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "arrow.down.doc.fill"))
        icon.tintColor = .systemGreen
        icon.contentMode = .scaleAspectFit
        icon.widthAnchor.constraint(equalToConstant: 28).isActive = true

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2

        let titleLabel = UILabel()
        titleLabel.text = "Downloading File"
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)

        progressLabel.text = "0% complete"
        progressLabel.font = .preferredFont(forTextStyle: .caption1)
        progressLabel.textColor = .secondaryLabel

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(progressLabel)

        hStack.addArrangedSubview(icon)
        hStack.addArrangedSubview(textStack)
        progressTarget.addSubview(hStack)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: progressTarget.topAnchor, constant: 14),
            hStack.leadingAnchor.constraint(equalTo: progressTarget.leadingAnchor, constant: 14),
            hStack.trailingAnchor.constraint(equalTo: progressTarget.trailingAnchor, constant: -14),
            hStack.bottomAnchor.constraint(equalTo: progressTarget.bottomAnchor, constant: -14),
        ])

        container.addArrangedSubview(progressTarget)

        // Control buttons (Reset & Simulate)
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually

        var resetConfig = UIButton.Configuration.bordered()
        resetConfig.title = "Reset"
        resetButton.configuration = resetConfig
        resetButton.addTarget(self, action: #selector(resetProgress), for: .touchUpInside)

        var simConfig = UIButton.Configuration.filled()
        simConfig.title = "Simulate"
        simConfig.baseBackgroundColor = .systemGreen
        progressButton.configuration = simConfig
        progressButton.addTarget(self, action: #selector(simulateProgress), for: .touchUpInside)

        buttonStack.addArrangedSubview(resetButton)
        buttonStack.addArrangedSubview(progressButton)

        container.addArrangedSubview(buttonStack)

        return container
    }

    private func makeExampleSection(title: String, subtitle: String, contentView: UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 20

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        subtitleLabel.textColor = .secondaryLabel

        let innerStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, contentView])
        innerStack.axis = .vertical
        innerStack.spacing = 8
        innerStack.setCustomSpacing(2, after: titleLabel)
        innerStack.setCustomSpacing(12, after: subtitleLabel)
        innerStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(innerStack)

        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            innerStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            innerStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            innerStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])

        return card
    }

    // MARK: - Actions

    @objc private func toggleBubble() {
        isBubbleLoading.toggle()
        if isBubbleLoading {
            bubbleButton.showLuminaLoader(style: .bubble)
            updateButtonConfig(bubbleButton, title: "Stop", icon: "stop.fill")
        } else {
            bubbleButton.hideLuminaLoader()
            updateButtonConfig(bubbleButton, title: "Start Bubble", icon: "play.fill")
        }
    }

    @objc private func toggleRing() {
        isRingLoading.toggle()
        if isRingLoading {
            ringButton.showLuminaLoader(style: .ring())
            updateButtonConfig(ringButton, title: "Stop", icon: "stop.fill")
        } else {
            ringButton.hideLuminaLoader()
            updateButtonConfig(ringButton, title: "Start Ring", icon: "play.fill")
        }
    }

    @objc private func togglePulse() {
        isPulseLoading.toggle()
        if isPulseLoading {
            let ovalPath = UIBezierPath(ovalIn: pulseView.bounds).cgPath
            pulseView.showLuminaLoader(path: ovalPath, style: .pulse, speed: 0.8)
        } else {
            pulseView.hideLuminaLoader()
        }
    }

    @objc private func resetProgress() {
        progressTimer?.invalidate()
        progressTimer = nil
        currentProgress = 0
        progressButton.isEnabled = true

        guard let progressTarget = view.viewWithTag(888) else { return }
        progressTarget.updateLuminaProgress(value: 0)
        progressTarget.hideLuminaProgress()
        progressLabel.text = "0% complete"
    }

    @objc private func simulateProgress() {
        progressTimer?.invalidate()
        currentProgress = 0
        progressButton.isEnabled = false

        guard let progressTarget = view.viewWithTag(888) else { return }
        progressTarget.showLuminaProgress(value: 0)

        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.currentProgress = min(self.currentProgress + 0.01, 1.0)
                progressTarget.updateLuminaProgress(value: self.currentProgress)
                self.progressLabel.text = "\(Int(self.currentProgress * 100))% complete"
                if self.currentProgress >= 1.0 {
                    self.progressTimer?.invalidate()
                    self.progressTimer = nil
                    self.progressButton.isEnabled = true
                }
            }
        }
    }

    private func updateButtonConfig(_ button: UIButton, title: String, icon: String) {
        var config = button.configuration
        config?.title = title
        config?.image = UIImage(systemName: icon)
        button.configuration = config
    }
}

#Preview {
    UIKitExampleWrapperView()
}
