# LuminaKit

A lightweight iOS library that provides a beautiful, animated bubble loading indicator. The bubble traces the border of any view shape — rectangles, circles, capsules, or custom paths.

On **iOS 26+**, the bubble automatically uses Apple's **Liquid Glass** material for a premium, system-native look. On **iOS 18–25**, it falls back to a polished glass-morphic style.

<img width="400" height="841" alt="LuminaKitSample" src="https://github.com/user-attachments/assets/3b5ad487-96a5-4b13-ba9c-e90bd8069bc9" />

<!-- Video file https://github.com/user-attachments/assets/0e88076c-b597-40d0-a74f-3b4a88e21431 -->

## Requirements

- iOS 18.0+
- Swift 6.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iarafathsn/LuminaKit.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → enter `https://github.com/iarafathsn/LuminaKit.git`

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'LuminaLoaderKit', '~> 1.0'
```

Then run:

```bash
pod install
```

### Carthage

Add the following to your `Cartfile`:

```
github "iarafathsn/LuminaKit" ~> 1.0
```

Then run:

```bash
carthage update --use-xcframeworks
```

Drag the built `LuminaKit.xcframework` from `Carthage/Build/` into your project.

## Usage

### SwiftUI

```swift
import LuminaKit

struct ContentView: View {
    @State private var isLoading = false

    var body: some View {
        // Standard rectangle (default)
        Button("Submit") {
            isLoading.toggle()
        }
        .luminaLoader(isAnimating: $isLoading)

        // Rounded rectangle shape
        Button("Rounded") {
            isLoading.toggle()
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .luminaLoader(
            isAnimating: $isLoading,
            shape: RoundedRectangle(cornerRadius: 12)
        )

        // Circle or Capsule shape
        Image(systemName: "person.fill")
            .clipShape(Circle())
            .luminaLoader(
                isAnimating: $isLoading,
                shape: Circle()
            )

        // Full customization
        Button("Customized") {
            isLoading.toggle()
        }
        .luminaLoader(
            isAnimating: $isLoading,
            shape: Capsule(),
            bubbleSize: 12,
            speed: 0.8
        )
    }
}
```

### UIKit

```swift
import LuminaKit

// One-liner convenience
button.showLuminaLoader()
button.hideLuminaLoader()

// With custom path (for non-rectangular shapes)
let ovalPath = UIBezierPath(ovalIn: imageView.bounds).cgPath
imageView.showLuminaLoader(path: ovalPath)

// With customization
button.showLuminaLoader(bubbleSize: 12, speed: 0.8)

// Object-based control
let loader = LuminaLoaderUIView(
    configuration: LuminaConfiguration(bubbleSize: 12, speed: 0.8)
)
myView.addSubview(loader)
loader.frame = myView.bounds
loader.startAnimating()
loader.stopAnimating()
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `isAnimating` | `Binding<Bool>` | — | Controls the animation state (SwiftUI) |
| `shape` | `any Shape` | `Rectangle()` | The border shape to follow (SwiftUI) |
| `path` | `CGPath?` | Auto-detected | The border path to follow (UIKit) |
| `bubbleSize` | `CGFloat` | `10` | Diameter of the bubble in points |
| `speed` | `CGFloat` | `0.5` | Revolutions per second |

## License

MIT License. See [LICENSE](LICENSE) for details.
