import ComposableArchitecture
import XCTest
@testable import VisionSimulation
@testable import CameraTab

final class CameraTabAppClipTests: XCTestCase {
  
  @MainActor
  func testAppClipDownloadPrompt_NotInitiallyRevealed() async {
    let clock = TestClock()
    let store = TestStore(
      initialState: CameraTab.State(vision: .typical),
      reducer: CameraTab.init,
      withDependencies: {
        $0.suspendingClock = clock
        $0.appClip.isAppClip = { true }
        $0.analytics.track = { _ in }
      }
    )
    await store.send(.onAppear)
    await clock.run()
    store.assert {
      $0.appClip.showDownloadPrompt = false
    }
  }

  @MainActor
  func testAppClipDownloadPrompt_Revealed_SometimeAfterVisionSimulationChange() async {
    let clock = TestClock()
    let store = TestStore(
      initialState: CameraTab.State(camera: .streaming, vision: .typical),
      reducer: CameraTab.init,
      withDependencies: {
        $0.suspendingClock = clock
        $0.appClip.isAppClip = { true }
        $0.analytics.track = { _ in }
        $0.visionSimulation.cameraChangeSimulation = { _ in }
      }
    )
    await store.send(.binding(.set(\.vision, .monochromat))) {
      $0.vision = .monochromat
    }
    await clock.advance(by: .seconds(2))
    await clock.run()
    await store.receive(.appClip(.revealDownloadPrompt)) {
      $0.appClip.showDownloadPrompt = true
    }
  }

  @MainActor
  func testAppClipDownloadPrompt_Revealed_SometimeAfterCameraStart() async {
    let clock = TestClock()
    let store = TestStore(
      initialState: CameraTab.State(camera: .streaming, vision: .typical),
      reducer: CameraTab.init,
      withDependencies: {
        $0.suspendingClock = clock
        $0.appClip.isAppClip = { true }
        $0.analytics.track = { _ in }
      }
    )
    await store.send(.camera(.startCameraResult(.success(CameraSuccess()))))
    await clock.advance(by: .seconds(2))
    await clock.run()
    await store.receive(.appClip(.revealDownloadPrompt)) {
      $0.appClip.showDownloadPrompt = true
    }
  }

  @MainActor
  func testMainApp_DoesNotRevealAppClipDownloadPrompt() async {
    let store = TestStore(
      initialState: CameraTab.State(vision: .typical),
      reducer: CameraTab.init,
      withDependencies: {
        $0.appClip.isAppClip = { false }
      }
    )
    await store.send(.appClip(.revealDownloadPrompt))
  }
}
