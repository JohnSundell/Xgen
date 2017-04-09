import PackageDescription

let package = Package(
    name: "Xgen",
    dependencies: [
        .Package(url: "git@github.com:johnsundell/files.git", majorVersion: 1)
    ]
)
