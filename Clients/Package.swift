// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "Clients",
  defaultLocalization: "en",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: .all(),
  dependencies: [
    .package(
      path: "../ColorVision"
    ),
    .package(
      url: "https://github.com/apple/swift-async-algorithms",
      from: Version(1, 0, 0)
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      branch: "shared-state-beta"
    ),
    .package(
      url: "https://github.com/firebase/firebase-ios-sdk",
      from: Version(10, 23, 0)
    )
  ],
  targets: [
    .client(
      .Analytics,
      dependencies: .FirebaseAnalytics
    ),
    .client(.AppClip),
    .test(.AppClip, dependencies: .VisionType),
    .client(
      .VisionSimulation,
      dependencies: .AsyncAlgorithms, .MetalVisionSimulation
    )
  ]
)

enum Client: String, CaseIterable {
  case Analytics
  case AppClip
  case VisionSimulation
}

// MARK: - Sugar

extension Target.Dependency {
  static let AsyncAlgorithms = Target.Dependency.product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
  static let ComposableArchitecture = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
  static let FirebaseAnalytics = Target.Dependency.product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
  static let MetalVisionSimulation = Target.Dependency.product(name: "MetalColorVisionSimulation", package: "ColorVision")
  static let VisionType = Target.Dependency.product(name: "VisionType", package: "ColorVision")

  static func client(_ client: Client) -> Target.Dependency {
    Target.Dependency.byName(name: client.rawValue)
  }
}

extension Target {
  static func client(_ client: Client, dependencies: Target.Dependency...) -> Target {
    .target(
      name: client.rawValue,
      dependencies: [.ComposableArchitecture] + dependencies
    )
  }

  static func client(_ client: Client, parent: Client, dependencies: Target.Dependency...) -> Target {
    .target(
      name: client.rawValue,
      dependencies: [.ComposableArchitecture, .client(parent)] + dependencies
    )
  }

  static func test(_ client: Client, dependencies: Target.Dependency...) -> Target {
    .testTarget(
      name: client.rawValue.appending("Tests"),
      dependencies: [.ComposableArchitecture, .client(client)] + dependencies
    )
  }
}

extension [Product] {
  static func all() -> [Product] {
    Client.allCases.map { .library($0) }
  }
}

extension Product {
  static func library(_ client: Client) -> Product {
    .library(name: client.rawValue, targets: [client.rawValue])
  }
}
