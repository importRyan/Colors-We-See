import StoreKit
import SwiftUI

struct UpgradeRequiredView: View {
  let reason: String
  let didTapOpenAppStore: () -> Void

  var body: some View {
    ContentUnavailableView(
      label: { Text(.UpgradeRequired.headline) },
      description: { Text(reason) },
      actions: {
        Button(
          String(localized: .UpgradeRequired.cta),
          action: didTapOpenAppStore
        )
        .buttonBorderShape(.capsule)
        .buttonStyle(.borderedProminent)
      }
    )
    .appStoreOverlay(isPresented: .constant(true)) {
      SKOverlay.AppConfiguration(appIdentifier: "id1645596758", position: .bottom)
    }
  }
}
