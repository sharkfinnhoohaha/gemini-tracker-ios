// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GeminiUsageTracker",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "GeminiUsageTracker",
            targets: ["GeminiUsageTracker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0")
    ],
    targets: [
        .executableTarget(
            name: "GeminiUsageTracker",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ]
        ),
    ]
)
