// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Fosdem",
    platforms: [
        .iOS("16.0")
    ],
    products: [
    ],
    dependencies: [
        .package(url: "https://github.com/yahoojapan/SwiftyXMLParser.git", from: "5.0.0"),
    ],
    targets: [
        .target(name: "Fosdem", path: "Fosdem"),
        .testTarget(
            name: "FosdemTests",
            dependencies: ["Fosdem"],
            path: "FosdemTests"
        ),
    ]
)
