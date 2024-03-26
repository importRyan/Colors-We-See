import SwiftUI

struct CameraErrorScreen: View {
  let error: String
  let didTapRecover: () -> Void

  var body: some View {
    ContentUnavailableView(
      label: { Text(.CameraError.headline) },
      description: { Text(error) },
      actions: { Button(String(localized: .CameraError.cta), action: didTapRecover) }
    )
  }
}
