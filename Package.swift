// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftInfo",
    products: [
        .library(name: "SwiftInfoCore", type: .dynamic, targets: ["SwiftInfoCore"]),
        .executable(name: "swiftinfo", targets: ["SwiftInfo"])
    ],
    targets: [
        .target(name: "SwiftInfoCore"),
        .target(
            name: "SwiftInfo",
            dependencies: ["SwiftInfoCore"]),
        .testTarget(
            name: "SwiftInfoTests",
            dependencies: ["SwiftInfo"]),
    ]
)
