// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Claudometer",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "Claudometer", path: "Sources/Claudometer"),
        .testTarget(name: "ClaudometerTests", dependencies: ["Claudometer"], path: "Tests/ClaudometerTests", resources: [.copy("Fixtures/usage.json")]),
    ]
)
