import SwiftUI

struct BootstrapFailedView: View {
  let reason: String

  var body: some View {
    ContentUnavailableView(
      String(localized: .BootstrapFailed.headline),
      image: "exclamationmark.square.fill",
      description: Text(reason)
    )
  }
}
