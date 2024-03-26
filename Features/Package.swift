// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "Features",
  defaultLocalization: "en",
  platforms: [.iOS(.v17), .macOS(.v14)],
  products: [
    .library(.Root),
    .library(.Common),
    .library(.CameraTab),
    .library(.LearnTab),
    .library(.Tabs),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      branch: "shared-state-beta"
    ),
    .package(
      url: "https://github.com/importRyan/Oklab",
      from: Version(1, 1, 1)
    ),
    .package(path: "../Clients"),
    .package(path: "../ColorVision"),
  ],
  targets: [
    .feature(
      .CameraTab,
      clients: .VisionSimulation,
      dependencies: .CpuColorVisionSimulation, .Oklab
    ),
    .test(.CameraTab),
    .feature(
      .Common,
      clients: .AppClip,
      dependencies: .VisionType
    ),
    .feature(.LearnTab),
    .feature(.PhotosTab),
    .feature(
      .Root,
      importing: .Tabs,
      clients: .AppClip, .VisionSimulation
    ),
    .test(.Root),
    .feature(
      .Tabs,
      importing: .CameraTab, .LearnTab, .PhotosTab
    ),
  ]
)

enum Feature: String, CaseIterable {
  case CameraTab
  case Common
  case LearnTab
  case PhotosTab
  case Root
  case Tabs
}

enum Client: String, CaseIterable {
  case Analytics
  case AppClip
  case VisionSimulation
}

// MARK: - Sugar

extension Target.Dependency {
  static let ComposableArchitecture = Target.Dependency.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
  static let CpuColorVisionSimulation = Target.Dependency.product(name: "CPUColorVisionSimulation", package: "ColorVision")
  static let Oklab = Target.Dependency.product(name: "Oklab", package: "Oklab")
  static let VisionType = Target.Dependency.product(name: "VisionType", package: "ColorVision")

  static func client(_ client: Client) -> Target.Dependency {
    Target.Dependency.product(name: client.rawValue, package: "Clients")
  }

  static func feature(_ feature: Feature) -> Target.Dependency {
    Target.Dependency.byName(name: feature.rawValue)
  }
}

extension Target {
  static func feature(
    _ feature: Feature,
    importing features: Feature...,
    clients: Client...,
    dependencies: Target.Dependency...
  ) -> Target {
    .target(
      name: feature.rawValue,
      dependencies: dependencies
      + clients.map { .client($0) }
      + features.map { .feature($0) }
      + [
        .ComposableArchitecture,
        .client(.Analytics),
      ]
      + (feature == .Common ? [] : [.feature(.Common)])
    )
  }

  static func test(_ feature: Feature) -> Target {
    .testTarget(
      name: feature.rawValue.appending("Tests"),
      dependencies: [.ComposableArchitecture, .feature(feature)]
    )
  }
}

extension Product {
  static func library(_ feature: Feature) -> Product {
    .library(name: feature.rawValue, targets: [feature.rawValue])
  }
}
