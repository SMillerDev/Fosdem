// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Fosdem",
    platforms: [
        .iOS(.v16),
    ],
    products: [
    ],
    dependencies: [
        .package(url: "https://github.com/SMillerDev/PentabarfKit", .branch("main"))
    ],
    targets: [
        .target(name: "Fosdem", dependencies: ["PentabarfKit"], path: "Fosdem"),
        .testTarget(
            name: "FosdemTests",
            dependencies: ["Fosdem"],
            path: "FosdemTests"
        ),
    ]
)
