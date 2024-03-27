import SwiftUI

// TODO: - SPM Plugin for Accessors
extension LocalizedStringResource  {
  enum BootstrapFailed: Namespace {
    static let headline = key("BootstrapFailed.Headline")
  }
  enum UpgradeRequired: Namespace {
    static let headline = key("UpgradeRequired.Headline")
    static let defaultReason = key("UpgradeRequired.DefaultReason")
    static let cta = key("UpgradeRequired.CTA")
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
