import PackageDescription

let package = Package(
    name: "Xgen",
    dependencies: [
        .Package(url: "https://github.com/johnsundell/files.git", majorVersion: 1)
    ]
)
