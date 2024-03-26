import SwiftUI

// TODO: - SPM Plugin for Accessors
extension LocalizedStringResource  {
  enum AppClip: Namespace {
    static let getAppCTA = key("AppClip.GetAppCTA")
  }
  enum CameraError: Namespace {
    static let headline = key("CameraError.Headline")
    static let cta = key("CameraError.CTA")
  }
  enum CameraPermissions: Namespace {
    static let headline = key("CameraPermissions.Headline")
    static let body = key("CameraPermissions.Body")
    static let cta = key("CameraPermissions.CTA")
  }
  enum CameraPermissionsDenied: Namespace {
    static let headline = key("CameraPermissionsDenied.Headline")
    static let body = key("CameraPermissionsDenied.Body")
    static let cta = key("CameraPermissionsDenied.CTA")
  }
  enum CameraUnavailable: Namespace {
    static let headline = key("CameraUnavailable.Headline")
    static let body = key("CameraUnavailable.Body")
  }
  enum SimulationPicker: Namespace {
    static let axLabelChangeSimulation = key("SimulationPicker.AXLabelChangeSimulation")
    static let axValueLessCommon = key("SimulationPicker.AXValueLessCommon")
    static let axValueMoreCommon = key("SimulationPicker.AXValueMoreCommon")
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
