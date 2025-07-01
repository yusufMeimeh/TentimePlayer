// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TentimePlayer",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TentimePlayer",
            targets: ["TentimePlayer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
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
            sources: ["Cache",
                      "Model",
                      "Helper",
                      "Model/Managers",
                      "Model/Player",
                      "Helper/Extensions",
                      "RemoteCommand",
                      "View",
                      "Cache/FairPlay",
                      "Cache/FairPlay/Protocol",
                      "Cache/FairPlay/Helper",
                      "Cache/FairPlay/Helper/FileManaging",
                      "Cache/FairPlay/AVAssetLoader/",
                      "Cache/FairPlay/AVContentKey/",
                      "Cache/FairPlay/Helper/UserDefaultsManaging",
                      "Cache/FairPlay/AVAssetLoader/OfflineKeyProcess",
                      "Cache/FairPlay/AVContentKey/OfflineKeyProcess",
                      "Cache/FairPlay/AVAssetLoader/OnlineKeyProcess",
                      "Cache/FairPlay/AVContentKey/OnlineKeyProcess"],
            resources: [
                .process("Design/InlinePlayer.xib"),
                .process("Design/TenTimeMediaPlayerView.xib"),
                .process("Design/UpNextContentView.xib"),
                .process("Resources")
            ],
            publicHeadersPath: ""
        ),
        .binaryTarget(
            name: "GoogleInteractiveMediaAds",
            path: "Frameworks/GoogleInteractiveMediaAds.xcframework"
        ),
        .testTarget(
            name: "Tests",
            dependencies: ["TentimePlayer"],
            sources: ["TentimePlayerTests/FairPlayTest",
                      "TentimePlayerTests/Mock"]
        )
    ]
)
