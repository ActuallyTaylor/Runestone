// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Runestone",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(name: "Runestone", targets: ["Runestone"])
    ],
    dependencies: [
        .package(url: "https://github.com/ActuallyTaylor/tree-sitter-spm", branch: "master")
    ],
    targets: [
        .target(name: "Runestone", dependencies: [
            .product(name: "TreeSitter", package: "tree-sitter-spm")
        ], resources: [
            .process("TextView/Theme/Theme.xcassets")
        ]),
    ]
)
