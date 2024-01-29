// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hostmon",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(name: "hostmon", targets: ["hostmon"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(name: "hostmon", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "libhostmon"
        ]),
        .target(name: "libhostmon", dependencies: ["libsmc"]),
        .target(name: "libsmc"),
        .testTarget(
            name: "libhostmonTests",
            dependencies: ["libhostmon"])
    ]
)
