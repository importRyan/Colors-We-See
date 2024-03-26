import Analytics
import Common
import ComposableArchitecture
import SwiftUI
import VisionSimulation
import VisionType

@Reducer
package struct Camera {
  @ObservableState
  package enum State: Codable, Equatable {
    case permissions(CameraPermissions.State)
    case streaming
    case paused
    case resuming
    case error(String)

    static let initialState = State.permissions(.initialState)
  }

  package enum Action: Equatable {
    case onScenePhase(ScenePhase)
    case permissions(CameraPermissions.Action)
    case startCamera
    case startCameraResult(Result<CameraSuccess, CameraError>)
    case resumeCamera
    case resumeCameraComplete
    case pauseCamera
    case attemptErrorRecovery
  }

  @Dependency(\.visionSimulation) var visionSimulation
  @Dependency(AnalyticsClient.self) var analytics

  package var body: some ReducerOf<Camera> {
    Scope(
      state: \.permissions,
      action: \.permissions,
      child: CameraPermissions.init
    )
    Reduce { state, action in
      switch action {
      case .attemptErrorRecovery:
        state = .permissions(.initialState)
        return .send(.permissions(.determine))

      case .onScenePhase(let phase):
        switch phase {
        case .background, .inactive:
          if state == .streaming {
            return .send(.pauseCamera)
          }
          return .none

        case .active:
          fallthrough
        @unknown default:
          switch state {
          case .paused:
            return .send(.resumeCamera)
          case .permissions:
            return .send(.permissions(.determine))
          case .streaming, .resuming, .error:
            return .none
          }
        }

      case .permissions(.success):
        return .send(.startCamera)

      case .permissions:
        return .none

      case .pauseCamera:
        state = .paused
        return .run { _ in
          await visionSimulation.cameraStop()
        }

      case .resumeCamera:
        state = .resuming
        return .run { send in
          await visionSimulation.cameraRestart()
          await send(.resumeCameraComplete)
        }

      case .resumeCameraComplete:
        state = .streaming
        return .none

      case .startCamera:
        if state == .streaming { return .none }
        if state == .paused { return .send(.resumeCamera) }
        return .run { send in
          let result = await visionSimulation.cameraStart()
          await send(.startCameraResult(result))
        }

      case let .startCameraResult(.failure(error)):
        state = .error(error.localizedDescription)
        return .track {
          .event(.cameraStartFailure)
          .property(.reason, error.localizedDescription)
        }

      case .startCameraResult(.success):
        state = .streaming
        return .none

      }
    }
  }
}

extension Camera {
  struct FeedView: View {
    @Bindable var store: StoreOf<Camera>
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
      ZStack {
        switch store.state {
        case .permissions:
          if let store = store.scope(state: \.permissions, action: \.permissions) {
            CameraPermissions.Screen(store: store)
              .transition(.cameraReveal)
          }

        case .streaming, .resuming, .paused: 
          CameraFeedView()
            .transition(.cameraReveal)

        case .error(let error):
          CameraErrorScreen(
            error: error,
            didTapRecover: { store.send(.attemptErrorRecovery) }
          )
          .transition(.opacity.animation(.smooth))
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .onChange(of: scenePhase, initial: true) { _, newValue in
        store.send(.onScenePhase(newValue))
      }
    }
  }
}

private extension AnyTransition {
  static let cameraReveal = AnyTransition
    .scale(scale: 1.1).animation(.smooth)
    .combined(with: .opacity.animation(.linear))
}
