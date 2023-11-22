// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPureDOOM",
    products: [
        .library(name: "SwiftPureDOOM", targets: ["SwiftPureDOOM"])
    ],
    targets: [
        .target(name: "CPureDOOM", publicHeadersPath: "Headers"),
        .target(name: "SwiftPureDOOM", dependencies: ["CPureDOOM"])
    ]
)
