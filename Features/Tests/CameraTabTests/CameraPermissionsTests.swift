import ComposableArchitecture
import XCTest
@testable import VisionSimulation
@testable import CameraTab

final class CameraTabPermissionsTests: XCTestCase {
  @MainActor
  func testOnPermissionsDenied_CanPresentSettingsDeepLink_AndDetectChangesUponForegrounding() async {
    let authorizationResponse = ActorIsolated(Result<AuthorizationSuccess, AuthorizationError>.failure(.denied))
    let didShowSettings = ActorIsolated(false)
    let store = TestStore(
      initialState: CameraTab.State(camera: .permissions(.notRequested(isRequestInFlight: false)), vision: .typical),
      reducer: CameraTab.init,
      withDependencies: {
        $0.analytics.track = { _ in }
        $0.appClip.isAppClip = { false }
        $0.suspendingClock = ImmediateClock()
        $0.openURL = .init { url in
          let expectedURL = await UIApplication.openSettingsURLString
          XCTAssertEqual(url.absoluteString, expectedURL)
          await didShowSettings.setValue(true)
          return true
        }
        $0.visionSimulation.cameraAuthorizationStatus = { await authorizationResponse.value }
        $0.visionSimulation.cameraAuthorize = { await authorizationResponse.value }
        $0.visionSimulation.cameraStart = { .success(CameraSuccess()) }
      }
    )
    store.exhaustivity = .off
    
    // User first denies permission
    await store.send(.camera(.permissions(.request))) {
      $0.camera = .permissions(.notRequested(isRequestInFlight: true))
    }
    await store.receive(.camera(.permissions(.requestResult(.failure(.denied))))) {
      $0.camera = .permissions(.denied)
    }

    // User then deep links to settings to restore permission
    await store.send(.camera(.permissions(.showSettings)))
    await store.send(.camera(.onScenePhase(.background)))
    await didShowSettings.withValue { XCTAssertTrue($0) }
    await authorizationResponse.setValue(.success(AuthorizationSuccess()))

    // User returns to app
    await store.send(.camera(.onScenePhase(.active)))
    await store.receive(.camera(.permissions(.success)))
    await store.receive(.camera(.startCamera))
  }

  @MainActor
  func testOnPermissionsSuccess_StartsCamera() async {
    let store = TestStore(
      initialState: CameraTab.State(camera: .permissions(.notRequested(isRequestInFlight: false)), vision: .typical),
      reducer: CameraTab.init,
      withDependencies: {
        $0.analytics.track = { _ in }
        $0.appClip.isAppClip = { false }
        $0.suspendingClock = ImmediateClock()
        $0.visionSimulation.cameraAuthorize = { .success(AuthorizationSuccess())}
        $0.visionSimulation.cameraStart = { .success(CameraSuccess()) }
      }
    )
    store.exhaustivity = .off
    await store.send(.camera(.permissions(.request)))
    await store.receive(.camera(.permissions(.success)))
    await store.receive(.camera(.startCamera))
  }
}
