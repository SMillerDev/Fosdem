// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Fosdem",
    platforms: [
        .iOS(.v16),
    ],
    products: [
    ],
    dependencies: [
        .package(url: "https://github.com/yahoojapan/SwiftyXMLParser.git", from: "5.0.0"),
    ],
    targets: [
        .target(name: "Fosdem", dependencies: ["SwiftyXMLParser"], path: "Fosdem"),
        .testTarget(
            name: "FosdemTests",
            dependencies: ["Fosdem"],
            path: "FosdemTests"
        ),
    ]
)
