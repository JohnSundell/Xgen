// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Xgen",
    products: [
        .library(name: "Xgen", targets: ["Xgen"])
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Xgen",
            dependencies: ["Files"],
            path: "Sources"
        ),
        .testTarget(
            name: "XgenTests",
            dependencies: ["Xgen"],
            path: "Tests"
        )
    ]
)
