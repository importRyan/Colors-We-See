import Analytics
import AppClip
import Common
import ComposableArchitecture
import SwiftUI
import VisionSimulation

@Reducer
struct Bootstrap {

  @ObservableState
  enum State: Codable, Equatable {
    case initialState
    case failed(reason: String)
  }

  enum Action {
    case boot
    case failed(reason: String)
    case complete
  }

  @Dependency(\.appClip.markLaunch) var markAppClipLaunch
  @Dependency(VisionSimulationClient.self) private var vision

  var body: some ReducerOf<Bootstrap> {
    Reduce { state, action in
      switch action {
      case .boot:
        return .concatenate(
          .track { .event(.appBootstrapStart) },
          .run { send in
            markAppClipLaunch()

            let sharedState = Shared(wrappedValue: .typical, .visionType)
            // Theoretically impossible for targeted devices to fail.
            try vision.initialize(sharedState.wrappedValue)

            await send(.complete)
          } catch: { error, send in
            await send(.failed(reason: error.localizedDescription))
          }
        )

      case .complete:
        return .track { .event(.appBootstrapSuccess) }

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

        case .failed(let reason):
          ContentUnavailableView(
            String(localized: .BootstrapFailed.headline),
            image: "exclamationmark.square.fill",
            description: Text(reason)
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
