// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Runestone",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "Runestone", targets: ["Runestone"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ActuallyTaylor/tree-sitter-spm", branch: "master")
    ],
    targets: [
        .target(name: "Runestone", dependencies: [
            .product(name: "TreeSitter", package: "tree-sitter-spm")
            ], resources: [.process("TextView/Appearance/Theme.xcassets")]),
        .target(name: "TestTreeSitterLanguages", cSettings: [.unsafeFlags(["-w"])]),
        .testTarget(name: "RunestoneTests", dependencies: ["Runestone", "TestTreeSitterLanguages"])
    ]
)
