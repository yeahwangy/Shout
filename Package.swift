// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Shout",
    products: [
        .library(name: "Shout", targets: ["Shout"]),
    ],
    dependencies: [
        .package(name: "Socket", url: "https://github.com/DimaRU/BlueSocket.git", .branch("master")),
        .package(name: "CSSH", url: "https://github.com/DimaRU/Libssh2Prebuild.git", .exact("1.9.0-OpenSSL_1_1_1h"))
    ],
    targets: [
        .target(name: "Shout", dependencies: ["CSSH", "Socket"]),
        .testTarget(name: "ShoutTests", dependencies: ["Shout"]),
    ]
)
#if os(watchOS)
package.targets.removeAll(where: { $0.name == "ShoutTests"})
#endif
