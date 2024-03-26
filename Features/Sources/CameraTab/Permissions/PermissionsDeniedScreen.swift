import SwiftUI

#if DEBUG
#Preview {
  PermissionsDeniedScreen(didTapShowSettings: {})
}
#endif

struct PermissionsDeniedScreen: View {
  let didTapShowSettings: () -> Void

  var body: some View {
    ContentUnavailableView(
      label: { Text(.CameraPermissionsDenied.headline) },
      description: { Text(.CameraPermissionsDenied.body) },
      actions: {
        Button(
          String(localized: .CameraPermissionsDenied.cta),
          action: didTapShowSettings
        )
        .buttonBorderShape(.capsule)
        .buttonStyle(.borderedProminent)
      }
    )
  }
}
