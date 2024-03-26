import SwiftUI

// TODO: - SPM Plugin for Accessors
extension LocalizedStringResource  {
  enum Typical: Namespace {
    static let explanation = key("Typical.Explanation")
    static let fullIntensityName = key("Typical.FullIntensityName")
    static let shortName = key("Typical.ShortName")
  }
  enum Deutan: Namespace {
    static let explanation = key("Deutan.Explanation")
    static let colloquialType = key("Deutan.ColloquialType")
    static let fullIntensityName = key("Deutan.FullIntensityName")
    static let shortName = key("Deutan.ShortName")
  }
  enum Protan: Namespace {
    static let explanation = key("Protan.Explanation")
    static let colloquialType = key("Protan.ColloquialType")
    static let fullIntensityName = key("Protan.FullIntensityName")
    static let shortName = key("Protan.ShortName")
  }
  enum Tritan: Namespace {
    static let explanation = key("Tritan.Explanation")
    static let colloquialType = key("Tritan.ColloquialType")
    static let fullIntensityName = key("Tritan.FullIntensityName")
    static let shortName = key("Tritan.ShortName")
  }
  enum Mono: Namespace {
    static let explanation = key("Mono.Explanation")
    static let colloquialType = key("Mono.ColloquialType")
    static let fullIntensityName = key("Mono.FullIntensityName")
    static let shortName = key("Mono.ShortName")
  }
}

extension LocalizedStringResource {
  protocol Namespace {}
}

extension LocalizedStringResource.Namespace {
  static func key(_ key: String.LocalizationValue) -> LocalizedStringResource {
    LocalizedStringResource(key, bundle: .atURL(Bundle.module.bundleURL))
  }
}
