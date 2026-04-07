// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "IconBrew",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "IconBrew",
            path: "Sources/IconBrew"
        )
    ]
)
