import Analytics

public enum AnalyticsEventName: String, AnalyticsEvent.Name {
  case appBootstrapStart
  case appBootstrapSuccess
  case appBootstrapFailure
  case appBootstrapFeatureFlagHydrationFailed
  case appBootstrapUpdateRequired
  case appClipInvocation
  case appClipStoreKitDownloadPromptPresented
  case appClipStoreKitOverlayPresented
  case appClipStoreKitOverlayDismissed
  case cameraPermissionsFailure
  case cameraPermissionsRequestTapped
  case cameraPermissionsShowSettingsTapped
  case cameraPermissionsSuccess
  case cameraStartFailure
  case changeVisionSimulationTapped
  case openAppStoreTapped
  case openAppStoreURLMalformed
  case viewCameraPermissions
  case viewCameraPermissionsDenied
  case viewCameraUnavailable
  case viewTabCamera
  case viewTabLearn
  case viewTabPhotos
}

public extension AnalyticsEvent {
  static func event(_ name: AnalyticsEventName) -> Self {
    Self(name: name)
  }
  static func event(_ name: AnalyticsEventName?) -> Self? {
    guard let name else { return nil }
    return Self(name: name)
  }
}
