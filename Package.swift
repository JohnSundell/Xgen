import PackageDescription

let package = Package(
    name: "Xgen",
    dependencies: [
        .Package(url: "https://github.com/JohnSundell/Files.git", majorVersion: 1)
    ]
)
