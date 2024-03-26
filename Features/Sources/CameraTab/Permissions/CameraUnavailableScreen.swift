import SwiftUI

#if DEBUG
#Preview {
  CameraUnavailableScreen()
}
#endif

struct CameraUnavailableScreen: View {
  var body: some View {
    ContentUnavailableView(
      String(localized: .CameraUnavailable.headline),
      systemImage: "camera",
      description: Text(.CameraUnavailable.body)
    )
  }
}
