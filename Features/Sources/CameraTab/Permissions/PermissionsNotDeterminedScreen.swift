import SwiftUI

#if DEBUG
#Preview {
  PermissionsNotDeterminedScreen(
    didTapGrantPermissions: {},
    showBusyIndicator: false
  )
}
#Preview("Loading") {
  PermissionsNotDeterminedScreen(
    didTapGrantPermissions: {},
    showBusyIndicator: true
  )
}
#endif

struct PermissionsNotDeterminedScreen: View {

  let didTapGrantPermissions: () -> Void
  let showBusyIndicator: Bool

  @Environment(\.dynamicTypeSize.isAccessibilitySize) private var isAccessibilitySize

  var body: some View {
    VStack {
      ColorVisionSimulationWaves()
        .containerRelativeFrame(.vertical) { height, _ in height / 3 }
        .padding(.bottom)
        .padding(.bottom)
        .padding(.bottom)

      ScrollView {
        VStack(spacing: 30) {
          Text(.CameraPermissions.headline)
            .multilineTextAlignment(.center)
            .font(.largeTitle)

          Text(.CameraPermissions.body)
            .multilineTextAlignment(.center)
            .font(.title3)
            .padding(.horizontal)
            .padding(.horizontal)
        }
        .padding(.horizontal, isAccessibilitySize ? 0 : 20)
      }
      .scrollBounceBehavior(.basedOnSize)

      Button(
        action: didTapGrantPermissions,
        label: {
          ZStack {
            Text(.CameraPermissions.cta)
              .padding(.horizontal)
              .opacity(showBusyIndicator ? 0 : 1)
            ProgressView()
              .opacity(showBusyIndicator ? 1 : 0)
              .tint(.white)
          }
        }
      )
      .font(.title2.weight(.medium))
      .buttonStyle(.borderedProminent)
      .buttonBorderShape(.capsule)
      .foregroundStyle(.background)
      .safeAreaPadding(.bottom)
    }
  }
}
