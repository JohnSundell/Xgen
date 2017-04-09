import PackageDescription

let package = Package(
    name: "XGen",
    dependencies: [
        .Package(url: "https://github.com/johnsundell/files.git", majorVersion: 1)
    ]
)
