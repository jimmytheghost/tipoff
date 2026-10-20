// swift-tools-version: 5.9
import PackageDescription
import Foundation
let frameworks = "/Library/Developer/CommandLineTools/Library/Developer/Frameworks"
let libraries = "/Library/Developer/CommandLineTools/Library/Developer/usr/lib"
let clt = FileManager.default.fileExists(atPath: frameworks + "/Testing.framework")
let package = Package(name: "Tipoff", platforms: [.macOS("15.0")], products: [
    .executable(name: "Tipoff", targets: ["Tipoff"]),
    .executable(name: "TipoffCheck", targets: ["TipoffCheck"])
], targets: [
    .target(name: "TipoffCore"),
    .executableTarget(name: "Tipoff", dependencies: ["TipoffCore"]),
    .executableTarget(name: "TipoffCheck", dependencies: ["TipoffCore"]),
    .testTarget(name: "TipoffTests", dependencies: ["TipoffCore"], resources: [.copy("Fixtures")],
        swiftSettings: clt ? [.unsafeFlags(["-F", frameworks])] : [],
        linkerSettings: clt ? [.unsafeFlags(["-F", frameworks, "-Xlinker", "-rpath", "-Xlinker", frameworks, "-Xlinker", "-rpath", "-Xlinker", libraries])] : [])
])
