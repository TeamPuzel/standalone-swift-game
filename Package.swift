// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Game",
    platforms: [.macOS(.v14)],
    targets: [
        // System
        .systemLibrary(name: "SDL", path: "sys", pkgConfig: "sdl2"),
        // Game
        .executableTarget(
            name: "Game",
            dependencies: ["SDL"],
            path: "src",
            swiftSettings: [
                .enableExperimentalFeature("Embedded"),
                .unsafeFlags([
                    "-whole-module-optimization"
                ])
            ]
        )
    ]
)
