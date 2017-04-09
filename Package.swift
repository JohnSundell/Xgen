import PackageDescription

let package = Package(
    name: "Xgen",
    dependencies: [
        .Package(url: "https://github.com/johnsundell/files.git", majorVersion: 1),
        .Package(url: "https://github.com/johnsundell/shellout.git", majorVersion: 1)
    ]
)
