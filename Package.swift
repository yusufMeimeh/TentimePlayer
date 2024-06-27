// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TentimePlayer",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TentimePlayer",
            targets: ["TentimePlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TentimePlayer",
            dependencies: [
                           "Kingfisher",
                           "GoogleInteractiveMediaAds"
                       ],
            path: "Sources/TentimePlayer",
            exclude: ["Tests"],
            sources: ["Cache", "Model", "RemoteCommand", "View"],
            publicHeadersPath: ""
        ),
        .binaryTarget(
            name: "GoogleInteractiveMediaAds",
            path: "Frameworks/GoogleInteractiveMediaAds.xcframework"
        ),
        
    ]
)
