// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MessageRouter",
    products: [
        .library(
            name: "MessageRouter",
            targets: ["MessageRouter"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "MessageRouter",
            dependencies: []),
        .testTarget(
            name: "MessageRouterTests",
            dependencies: ["MessageRouter"]),
    ]
)
