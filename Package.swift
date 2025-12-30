// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FasalRakshak",
    defaultLocalization: "hi",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FasalRakshak",
            targets: ["FasalRakshak"]),
    ],
    dependencies: [
        // Add external dependencies here if needed
    ],
    targets: [
        .target(
            name: "FasalRakshak",
            dependencies: [],
            path: "FasalRakshak",
            resources: [
                .process("Resources"),
                .process("Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "FasalRakshakTests",
            dependencies: ["FasalRakshak"],
            path: "FasalRakshakTests"
        ),
    ]
)
