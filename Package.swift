// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Workflow",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v8),
        .macCatalyst(.v15),
        .tvOS(.v12),
    ],
    products: [
        // MARK: Workflow

        .singleTargetLibrary("Workflow"),
        .singleTargetLibrary("WorkflowTesting"),

        // MARK: WorkflowUI

        .singleTargetLibrary("WorkflowUI"),
        .singleTargetLibrary("WorkflowSwiftUI"),

        // MARK: WorkflowConcurrency

        .singleTargetLibrary("WorkflowConcurrency"),
        .singleTargetLibrary("WorkflowConcurrencyTesting"),

        // MARK: WorkflowReactiveSwift

        .singleTargetLibrary("WorkflowReactiveSwift"),
        .singleTargetLibrary("WorkflowReactiveSwiftTesting"),

        // MARK: ViewEnvironment

        .singleTargetLibrary("ViewEnvironment"),

        // MARK: ViewEnvironmentUI

        .singleTargetLibrary("ViewEnvironmentUI"),
    ],
    dependencies: [
		.package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", branch: "swift-concurrency"),
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0" ..< "601.0.0-prerelease"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.2.1"),
    ],
    targets: [
        // MARK: Workflow

        .target(
            name: "Workflow",
            dependencies: ["ReactiveSwift"],
            path: "Workflow/Sources"
        ),
        .testTarget(
            name: "WorkflowTests",
            dependencies: ["Workflow"],
            path: "Workflow/Tests"
        ),
        .target(
            name: "WorkflowTesting",
            dependencies: [
                "Workflow",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ],
            path: "WorkflowTesting/Sources",
            linkerSettings: [.linkedFramework("XCTest")]
        ),
        .testTarget(
            name: "WorkflowTestingTests",
            dependencies: ["WorkflowTesting"],
            path: "WorkflowTesting/Tests"
        ),

        // MARK: WorkflowUI

        .target(
            name: "WorkflowUI",
            dependencies: ["Workflow", "ViewEnvironment", "ViewEnvironmentUI"],
            path: "WorkflowUI/Sources"
        ),
        .testTarget(
            name: "WorkflowUITests",
            dependencies: ["WorkflowUI", "WorkflowReactiveSwift"],
            path: "WorkflowUI/Tests"
        ),

        // MARK: WorkflowSwiftUI

        .target(
            name: "WorkflowSwiftUI",
            dependencies: [
                "Workflow",
                "WorkflowUI",
                "WorkflowSwiftUIMacros",
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            ],
            path: "WorkflowSwiftUI/Sources"
        ),
        .testTarget(
            name: "WorkflowSwiftUITests",
            dependencies: ["WorkflowSwiftUI"],
            path: "WorkflowSwiftUI/Tests"
        ),
        .macro(
            name: "WorkflowSwiftUIMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            path: "WorkflowSwiftUIMacros/Sources"
        ),

        // MARK: WorkflowConcurrency

        .target(
            name: "WorkflowConcurrency",
            dependencies: ["Workflow"],
            path: "WorkflowConcurrency/Sources"
        ),
        .testTarget(
            name: "WorkflowConcurrencyTests",
            dependencies: ["WorkflowConcurrencyTesting"],
            path: "WorkflowConcurrency/Tests"
        ),
        .target(
            name: "WorkflowConcurrencyTesting",
            dependencies: ["WorkflowConcurrency", "WorkflowTesting"],
            path: "WorkflowConcurrency/Testing",
            linkerSettings: [.linkedFramework("XCTest")]
        ),
        .testTarget(
            name: "WorkflowConcurrencyTestingTests",
            dependencies: ["WorkflowConcurrencyTesting"],
            path: "WorkflowConcurrency/TestingTests"
        ),

        // MARK: WorkflowReactiveSwift

        .target(
            name: "WorkflowReactiveSwift",
            dependencies: ["ReactiveSwift", "Workflow"],
            path: "WorkflowReactiveSwift/Sources"
        ),
        .testTarget(
            name: "WorkflowReactiveSwiftTests",
            dependencies: ["WorkflowReactiveSwiftTesting"],
            path: "WorkflowReactiveSwift/Tests"
        ),
        .target(
            name: "WorkflowReactiveSwiftTesting",
            dependencies: ["WorkflowReactiveSwift", "WorkflowTesting"],
            path: "WorkflowReactiveSwift/Testing",
            linkerSettings: [.linkedFramework("XCTest")]
        ),
        .testTarget(
            name: "WorkflowReactiveSwiftTestingTests",
            dependencies: ["WorkflowReactiveSwiftTesting"],
            path: "WorkflowReactiveSwift/TestingTests"
        ),

        // MARK: ViewEnvironment

        .target(
            name: "ViewEnvironment",
            path: "ViewEnvironment/Sources"
        ),

        // MARK: ViewEnvironmentUI

        .target(
            name: "ViewEnvironmentUI",
            dependencies: ["ViewEnvironment"],
            path: "ViewEnvironmentUI/Sources"
        )
    ],
    swiftLanguageVersions: [.v5]
)

// MARK: Helpers

extension PackageDescription.Product {
    static func singleTargetLibrary(
        _ name: String
    ) -> PackageDescription.Product {
        .library(name: name, targets: [name])
    }
}

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableExperimentalFeature("StrictConcurrency=targeted"))
    target.swiftSettings = settings
}
