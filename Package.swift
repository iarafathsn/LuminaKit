// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LuminaKit",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "LuminaKit",
            targets: ["LuminaKit"]
        ),
    ],
    targets: [
        .target(
            name: "LuminaKit",
            path: "Sources/LuminaKit"
        ),
        .testTarget(
            name: "LuminaKitTests",
            dependencies: ["LuminaKit"],
            path: "Tests/LuminaKitTests"
        ),
    ]
)
