// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DynamicWin",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "DynamicWin", targets: ["DynamicWin"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "DynamicWin",
            dependencies: [],
            path: "Sources"
        )
    ]
)
