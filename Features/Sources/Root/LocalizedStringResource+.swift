import SwiftUI

// TODO: - SPM Plugin for Accessors
extension LocalizedStringResource  {
  enum BootstrapFailed: Namespace {
    static let headline = key("BootstrapFailed.Headline")
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
