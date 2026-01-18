// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Fosdem",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
    ],
    dependencies: [
        .package(url: "https://github.com/SMillerDev/PentabarfKit", branch: "main"),
        .package(url: "https://github.com/Whiffer/swiftdata-sectionedquery", branch: "main"),
        .package(url: "https://codeberg.org/ctietze/timeline-ui.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "Fosdem",
            dependencies: ["PentabarfKit", "swiftdata-sectionedquery"],
            path: "Fosdem"
        ),
        .testTarget(
            name: "FosdemTests",
            dependencies: ["Fosdem"],
            path: "FosdemTests"
        ),
    ]
)
