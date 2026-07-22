# LuminaKit

A lightweight, high-performance iOS library that provides animated border-tracing loading indicators and progress bars for any view shape — rectangles, rounded rectangles, circles, capsules, or custom paths.

On **iOS 26+**, LuminaKit automatically leverages Apple's **Liquid Glass** material for a premium, system-native look. On **iOS 18–25**, it falls back to a polished glassmorphic glow effect.

| SwiftUI Demo | UIKit Demo |
| --- | --- |
| <img width="295" height="640" alt="SwiftUI_Demo" src="https://github.com/user-attachments/assets/d25aafd1-4862-4168-9142-81ec977c279c" /> | <img width="295" height="640" alt="UIKit_Demo" src="https://github.com/user-attachments/assets/700387c2-019b-4f96-b36a-7234433aa3d4" /> |

---

## What's New in 2.0.0 🎉

- **Multiple Animation Styles**: Choose between `.bubble` (classic moving bubble), `.ring(lineWidth:)` (continuous 360° rotating arc), and `.pulse` (breathing glow border).
- **Determinate Progress Indicators**: Border progress animation for SwiftUI (`.luminaProgress`) and UIKit (`showLuminaProgress`), complete with automatic zero-value hiding.
- **Advanced Color Customization (`LuminaColorMode` & `LuminaColors`)**:
  - `auto`: Automatically adapts to system Appearance (Light/Dark mode) with charcoal light mode defaults for maximum contrast.
  - `light` / `dark`: Explicit theme locking.
  - `custom(LuminaColors)`: Full control over primary color, stroke glow, shadow, and track colors.
  - `adaptive(light:dark:)`: Set distinct custom color palettes for light and dark modes.
- **Enhanced UIKit Performance**: Zero-jitter animation loop using `CADisplayLink` + seamless stroke wrap-around on circular and rectangular paths.

---

## Requirements

- **iOS 18.0+**
- **Swift 6.0+**
- **Xcode 16.0+**

---

## Installation

### Swift Package Manager

Add LuminaKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iarafathsn/LuminaKit.git", from: "2.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → search `https://github.com/iarafathsn/LuminaKit.git`

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'LuminaLoaderKit', '~> 2.0'
```

Then run:

```bash
pod install
```

### Carthage

Add the following to your `Cartfile`:

```ogdl
github "iarafathsn/LuminaKit" ~> 2.0
```

Then run:

```bash
carthage update --use-xcframeworks
```

---

## Usage

### 1. SwiftUI

#### Indeterminate Loader (Bubble, Ring, Pulse)

```swift
import SwiftUI
import LuminaKit

struct ContentView: View {
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            // 1. Standard Bubble Loader (Default)
            Button("Bubble Loader") { isLoading.toggle() }
                .padding()
                .luminaLoader(isAnimating: $isLoading)

            // 2. Rotating Ring Loader
            Button("Ring Loader") { isLoading.toggle() }
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .luminaLoader(
                    isAnimating: $isLoading,
                    shape: RoundedRectangle(cornerRadius: 12),
                    style: .ring(lineWidth: 3)
                )

            // 3. Breathing Pulse Loader
            Button("Pulse Loader") { isLoading.toggle() }
                .padding()
                .clipShape(Capsule())
                .luminaLoader(
                    isAnimating: $isLoading,
                    shape: Capsule(),
                    style: .pulse
                )
        }
    }
}
```

#### Determinate Progress Bar

```swift
struct ProgressViewExample: View {
    @State private var progress: CGFloat = 0.45

    var body: some View {
        Button("Upload File") { }
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .luminaProgress(
                value: $progress,
                shape: RoundedRectangle(cornerRadius: 10)
            )
    }
}
```

#### Custom & Adaptive Colors

```swift
// Single custom color scheme
let customTheme = LuminaColors(
    primary: .indigo,
    glow: .indigo.opacity(0.5)
)

Button("Custom Theme") { }
    .luminaLoader(
        isAnimating: $isLoading,
        colorMode: .custom(customTheme)
    )

// Adaptive Light & Dark mode colors
let adaptiveMode = LuminaColorMode.adaptive(
    light: LuminaColors(primary: .blue),
    dark: LuminaColors(primary: .cyan)
)

Button("Adaptive Theme") { }
    .luminaLoader(
        isAnimating: $isLoading,
        colorMode: adaptiveMode
    )
```

---

### 2. UIKit

#### Indeterminate Loader

```swift
import UIKit
import LuminaKit

// Show loader on any UIView or UIButton
button.showLuminaLoader(style: .bubble)

// Ring style with custom speed
button.showLuminaLoader(style: .ring(lineWidth: 4), speed: 0.8)

// Hide loader
button.hideLuminaLoader()

// Object-based instantiation
let loaderView = LuminaLoaderUIView(
    configuration: LuminaConfiguration(style: .ring(lineWidth: 3))
)
myView.addSubview(loaderView)
loaderView.frame = myView.bounds
loaderView.startAnimating()
```

#### Determinate Progress Bar

```swift
// Show progress indicator (0.0 to 1.0)
cardView.showLuminaProgress(value: 0.25)

// Update progress during task
cardView.updateLuminaProgress(value: 0.85)

// Hide progress when complete
cardView.hideLuminaProgress()
```

---

## Configuration & API Reference

### `LuminaLoaderStyle`
- `.bubble`: Glowing bubble travelling along the border.
- `.ring(lineWidth: CGFloat)`: Smooth rotating arc along the border.
- `.pulse`: Border glow pulsing in and out.

### `LuminaColorMode`
- `.auto`: Adapts to Light (charcoal/dark contrast) and Dark (glowing cyan/white) appearance.
- `.light`: Enforces light mode color scheme.
- `.dark`: Enforces dark mode color scheme.
- `.custom(LuminaColors)`: Uses custom colors.
- `.adaptive(light: LuminaColors, dark: LuminaColors)`: Different custom colors for light/dark modes.

### `LuminaColors`
- `primary`: Main accent color.
- `glow`: Color for stroke glow effect.
- `shadow`: Color for bubble shadow.
- `progressTrack`: Color for underlying progress track path.

---

## License

LuminaKit is available under the **MIT License**. See [LICENSE](LICENSE) for details.
