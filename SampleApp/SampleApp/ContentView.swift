import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("SwiftUI", systemImage: "swift") {
                SwiftUIExamplesView()
            }

            Tab("UIKit", systemImage: "uiwindow.split.2x1") {
                UIKitExampleWrapperView()
            }
        }
    }
}

#Preview {
    ContentView()
}
