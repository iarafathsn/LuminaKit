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
    private let roundedButton = UIButton(type: .system)
    private let circleView = UIView()
    private let pillButton = UIButton(type: .system)

    // Tracking state
    private var isRoundedLoading = false
    private var isCircleLoading = false
    private var isPillLoading = false

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
        // Info label
        let infoLabel = UILabel()
        infoLabel.text = "Tap any example to toggle the loader"
        infoLabel.font = .preferredFont(forTextStyle: .subheadline)
        infoLabel.textColor = .secondaryLabel
        infoLabel.textAlignment = .center
        stackView.addArrangedSubview(infoLabel)

        // 1. Rounded Rectangle Button
        stackView.addArrangedSubview(
            makeExampleSection(
                title: "Rounded Rectangle",
                subtitle: "Auto-detects bounds & cornerRadius",
                contentView: makeRoundedButton()
            )
        )

        // 2. Circle View
        stackView.addArrangedSubview(
            makeExampleSection(
                title: "Circle",
                subtitle: "Custom CGPath: UIBezierPath(ovalIn:)",
                contentView: makeCircleView()
            )
        )

        // 3. Pill / Capsule Button
        stackView.addArrangedSubview(
            makeExampleSection(
                title: "Capsule / Pill",
                subtitle: "Capsule path from cornerRadius = height/2",
                contentView: makePillButton()
            )
        )
    }

    // MARK: - Example Builders

    private func makeRoundedButton() -> UIView {
        var config = UIButton.Configuration.filled()
        config.title = "Start Loading"
        config.image = UIImage(systemName: "play.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium
        roundedButton.configuration = config
        roundedButton.layer.cornerRadius = 12
        roundedButton.clipsToBounds = true
        roundedButton.addTarget(self, action: #selector(toggleRoundedLoader), for: .touchUpInside)
        roundedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return roundedButton
    }

    private func makeCircleView() -> UIView {
        let container = UIView()

        let size: CGFloat = 80
        circleView.backgroundColor = .systemPurple
        circleView.layer.cornerRadius = size / 2
        circleView.clipsToBounds = true
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.isUserInteractionEnabled = true

        let imageView = UIImageView(image: UIImage(systemName: "person.fill"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(imageView)

        container.addSubview(circleView)

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circleView.topAnchor.constraint(equalTo: container.topAnchor),
            circleView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            circleView.widthAnchor.constraint(equalToConstant: size),
            circleView.heightAnchor.constraint(equalToConstant: size),

            imageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalToConstant: 32),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleCircleLoader))
        circleView.addGestureRecognizer(tap)

        return container
    }

    private func makePillButton() -> UIView {
        var config = UIButton.Configuration.filled()
        config.title = "Download"
        config.image = UIImage(systemName: "arrow.down.circle.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = .systemGreen
        config.cornerStyle = .capsule
        pillButton.configuration = config
        pillButton.addTarget(self, action: #selector(togglePillLoader), for: .touchUpInside)
        pillButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return pillButton
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

    @objc private func toggleRoundedLoader() {
        isRoundedLoading.toggle()
        if isRoundedLoading {
            roundedButton.showLuminaLoader()
            updateButtonConfig(roundedButton, title: "Stop Loading", icon: "stop.fill")
        } else {
            roundedButton.hideLuminaLoader()
            updateButtonConfig(roundedButton, title: "Start Loading", icon: "play.fill")
        }
    }

    @objc private func toggleCircleLoader() {
        isCircleLoading.toggle()
        if isCircleLoading {
            // Use an oval path for the circle shape
            let ovalPath = UIBezierPath(ovalIn: circleView.bounds).cgPath
            circleView.showLuminaLoader(path: ovalPath)
        } else {
            circleView.hideLuminaLoader()
        }
    }

    @objc private func togglePillLoader() {
        isPillLoading.toggle()
        if isPillLoading {
            // Build a capsule path: cornerRadius = half the height
            let bounds = pillButton.bounds
            let capsulePath = UIBezierPath(
                roundedRect: bounds,
                cornerRadius: bounds.height / 2
            ).cgPath
            pillButton.showLuminaLoader(path: capsulePath)
            updateButtonConfig(pillButton, title: "Cancel", icon: "xmark.circle.fill")
        } else {
            pillButton.hideLuminaLoader()
            updateButtonConfig(pillButton, title: "Download", icon: "arrow.down.circle.fill")
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
