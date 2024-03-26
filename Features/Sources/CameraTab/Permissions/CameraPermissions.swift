import Analytics
import Common
import CPUColorVisionSimulation
import SwiftUI
import ComposableArchitecture
import VisionSimulation
import VisionType

@Reducer
package struct CameraPermissions {

  @ObservableState
  package enum State: Codable, Equatable {
    case initialState
    case notRequested(isRequestInFlight: Bool)
    case denied
    case unavailable
  }

  package enum Action: Equatable {
    case determine
    case determineAuthorizationError(AuthorizationError)
    case request
    case requestResult(Result<AuthorizationSuccess, AuthorizationError>)
    case showSettings
    case success
  }

  @Dependency(\.openURL) var openURL
  @Dependency(\.visionSimulation) var visionSimulation

  package var body: some ReducerOf<CameraPermissions> {
    Reduce { state, action in
      switch action {

      case .determine:
        return .run { send in
          switch await visionSimulation.cameraAuthorizationStatus() {
          case .success:
            await send(.success)
          case .failure(let reason):
            await send(.determineAuthorizationError(reason))
          }
        }

      case .determineAuthorizationError(let reason):
        state = reason.state
        let optionalAnalytics = AnalyticsEventName.forAuthorizationDetermination(state)
        return .track { .event(optionalAnalytics) }

      case .request:
        if case .notRequested = state {
          state = .notRequested(isRequestInFlight: true)
        }
        return .merge(
          .run { send in
            let userPreference = await visionSimulation.cameraAuthorize()
            await send(.requestResult(userPreference))
          },
          .track { .event(.cameraPermissionsRequestTapped) }
        )

      case .requestResult(.success):
        return .merge(
          .send(.success),
          .track { .event(.cameraPermissionsSuccess) }
        )

      case let .requestResult(.failure(error)):
        state = error.state
        return .track {
          .event(.cameraPermissionsFailure)
          .property(.reason, error.localizedDescription)
        }

      case .showSettings:
        return .merge(
          .run { _ in
            guard let url = await URL(string: UIApplication.openSettingsURLString) else { return }
            await openURL(url)
          },
          .track { .event(.cameraPermissionsShowSettingsTapped) }
        )

      case .success:
        return .none
      }
    }
  }
}

private extension AnalyticsEventName {
  static func forAuthorizationDetermination(_ state: CameraPermissions.State) -> AnalyticsEventName? {
    switch state {
    case .initialState: nil
    case .notRequested: .viewCameraPermissions
    case .denied: .viewCameraPermissionsDenied
    case .unavailable: .viewCameraUnavailable
    }
  }
}

private extension AuthorizationError {
  var state: CameraPermissions.State {
    switch self {
    case .denied: .denied
    case .notDetermined: .notRequested(isRequestInFlight: false)
    case .restricted, .unknown: .unavailable
    }
  }
}

extension CameraPermissions {
  struct Screen: View {
    @Bindable var store: StoreOf<CameraPermissions>
    var body: some View {
      ZStack {
        switch store.state {
        case .initialState: 
          EmptyView()

        case .notRequested(let isRequestInFlight):
          PermissionsNotDeterminedScreen(
            didTapGrantPermissions: { store.send(.request) },
            showBusyIndicator: isRequestInFlight
          )

        case .denied:
          PermissionsDeniedScreen(
            didTapShowSettings: { store.send(.showSettings) }
          )

        case .unavailable:
          CameraUnavailableScreen()
        }
      }
    }
  }
}
