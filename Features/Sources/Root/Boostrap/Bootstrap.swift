import Analytics
import AppClip
import Common
import ComposableArchitecture
import FeatureFlags
import LaunchEnvironment
import SwiftUI
import VisionSimulation

@Reducer
struct Bootstrap {

  @ObservableState
  enum State: Codable, Equatable {
    case initialState
    case failed(reason: String)
    case updateRequired(reason: String)
  }

  enum Action: Equatable {
    case boot
    case failed(reason: String)
    case updateRequired(reason: String?)
    case openAppStore
    case complete
  }

  @Dependency(\.openURL) private var openURL
  @Dependency(\.analytics.track) private var track

  var body: some ReducerOf<Bootstrap> {
    Reduce { state, action in
      switch action {
      case .boot:
        return .concatenate(
          .track { .event(.appBootstrapStart) },
          .run(
            operation: bootstrap,
            catch: { error, send in
              await send(.failed(reason: error.localizedDescription))
            }
          )
        )

      case .complete:
        return .track { .event(.appBootstrapSuccess) }

      case .openAppStore:
        return .merge(
          .track { .event(.openAppStoreTapped) },
          .run { _ in
            guard let url = URL(string: "https://apps.apple.com/app/colors-we-see/id1645596758") else {
              track(.event(.openAppStoreURLMalformed))
              return
            }
            await openURL(url)
          }
        )

      case .updateRequired(let reason):
        state = .updateRequired(reason: reason ?? String(localized: .UpgradeRequired.defaultReason))
        return .track {
          .event(.appBootstrapUpdateRequired)
          .property(.reason, reason ?? "")
        }

      case .failed(let reason):
        state = .failed(reason: reason)
        return .track {
          .event(.appBootstrapFailure)
          .property(.reason, reason)
        }
      }
    }
  }

  struct Screen: View {
    @Bindable var store: StoreOf<Bootstrap>

    var body: some View {
      ZStack {
        switch store.state {
        case .initialState:
          ProgressView()

        case .updateRequired(let reason):
          UpgradeRequiredView(
            reason: reason,
            didTapOpenAppStore: { store.send(.openAppStore) }
          )

        case .failed(let reason):
          BootstrapFailedView(
            reason: reason
          )
        }
      }
      .task {
        // TODO: - Move to app delegate with deep link / App Clip feature
        store.send(.boot)
      }
    }
  }
}

@Sendable
private func bootstrap(_ send: Send<Bootstrap.Action>) async throws {
  @Dependency(\.analytics.track) var track
  @Dependency(\.appClip.markLaunch) var markAppClipLaunch
  @Dependency(\.featureFlags) var featureFlags
  @Dependency(\.launchEnvironment.currentVersion) var currentVersion
  @Dependency(VisionSimulationClient.self) var vision

  markAppClipLaunch()

  // Hydrate feature flags
  do {
    try await featureFlags.hydrate()
  } catch {
    track(
      .event(.appBootstrapFeatureFlagHydrationFailed)
      .property(.reason, error.localizedDescription)
    )
  }

  // Minimum/blocked version check
  do {
    let versionCheck = try featureFlags.value(for: VersionCheck.Flag.self)
    guard versionCheck.isCurrentVersionValid(currentVersion()) else {
      await send(.updateRequired(reason: versionCheck.prompt))
      return
    }
  } catch {
    track(
      .event(.nonfatal)
      .property(.variant, VersionCheck.Flag.key)
      .property(.reason, error.localizedDescription)
    )
  }

  // Start Metal (theoretically all devices for the minimum OS should pass)
  let sharedState = Shared(wrappedValue: .typical, .visionType)
  try vision.initialize(sharedState.wrappedValue)

  await send(.complete)
}
