// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "SwiftCMakeXCTesting",
  platforms: [
    .macOS(.v13)
  ],

  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-syntax.git", branch: "main"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .executableTarget(
      name: "GenerateSwiftXCTestMain",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        .product(name: "SwiftOperators", package: "swift-syntax"),
        .product(name: "SwiftParser", package: "swift-syntax"),
        .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
      ],
      path: "Sources",
      exclude: ["CMakeLists.txt"],
      // This setting is needed on Windows until SPM >5.9.0 is
      // released due to
      // https://github.com/apple/swift-package-manager/issues/7410
      swiftSettings: [.unsafeFlags(["-parse-as-library"])]
    ),

    .target(name: "DummyTestee",
            path: "Tests",
            exclude: ["XCTestImporter.swift", "CMakeLists.txt", "Tests.swift"],
            sources: [ "Dummy.swift"]),

    .target(name: "XCTestImporter",
            path: "Tests",
            exclude: ["Dummy.swift", "CMakeLists.txt", "Tests.swift"],
            sources: [ "XCTestImporter.swift" ] ),

    .testTarget(
      name: "Tests",
      dependencies: ["DummyTestee", "XCTestImporter"],
      path: "Tests",
      exclude: ["XCTestImporter.swift", "CMakeLists.txt", "Dummy.swift"],
      sources: ["Tests.swift"])
  ]
)
