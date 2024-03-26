import Analytics
@testable import AppClip
import Common
import ComposableArchitecture
import XCTest
import VisionType
@testable import Root

final class RootAppClipTests: XCTestCase {

  @MainActor
  func testOnAppClipInvocation_WhenNotYetBooted_DefersDeepLinking() async {
    let didChangeCameraSimulation = ActorIsolated(false)
    let store = appRootAppClipTestStore(
      initialState: .bootstrap(.initialState),
      didChangeCameraSimulation
    )

    // When booting: no deep link
    await store.send(.appDelegate(.onContinue(.deutanAppClip)))
    await store.receive(\.onAppClipInvocation, .deutanAppClip)
    let simulationDidChangeAfterInvocation = await didChangeCameraSimulation.value
    XCTAssertFalse(simulationDidChangeAfterInvocation)

    // After booting: expect deferred deep link
    await store.send(.bootstrap(.complete)) {
      $0 = .tab(.initialState)
    }
    await store.receive(\.onDeepLinkSetVisionType, .deutan) {
      $0.tab?.camera.vision = .deutan
    }
    let simulationDidChangeAfterBoot = await didChangeCameraSimulation.value
    XCTAssertTrue(simulationDidChangeAfterBoot)
  }

  @MainActor
  func testOnAppClipInvocation_WhenBooted_PerformsDeepLink() async {
    let didChangeCameraSimulation = ActorIsolated(false)
    let store = appRootAppClipTestStore(
      initialState: .tab(.initialState),
      didChangeCameraSimulation
    )
    store.exhaustivity = .off(showSkippedAssertions: false)

    // Assert deep link performed
    await store.send(.appDelegate(.onContinue(.deutanAppClip)))
    await store.receive(\.onDeepLinkSetVisionType, .deutan)
    let simulationDidChange = await didChangeCameraSimulation.value
    XCTAssertTrue(simulationDidChange)
    store.assert {
      $0.tab?.camera.vision = .deutan
    }
  }

  func testNotAppClip_UserTappedAppClipLink_WillNotAskSystemToPopTheAppClipCard() {
    let delegate = AppDelegate(
      store: .init(
        initialState: AppRoot.State.bootstrap(.initialState),
        reducer: AppRoot.init,
        withDependencies: {
          $0.appClip.isAppClip = { false }
        }
      )
    )
    XCTAssertTrue(delegate.application(.shared, continue: .deutanAppClip, restorationHandler: { _ in }))
  }
}

// MARK: - State Helpers

private func appRootAppClipTestStore(
  initialState: AppRoot.State,
  _ didChangeCameraSimulation: ActorIsolated<Bool>
) -> TestStore<AppRoot.State, AppRoot.Action> {
  TestStore(
    initialState: initialState,
    reducer: AppRoot.init,
    withDependencies: {
      $0.defaultAppStorage = TestUserDefaults()
      $0.analytics.track = { _ in }
      $0.appClip.isAppClip = { true }
      $0.appClip.setCurrentInvocation = { XCTAssertEqual($0, .deutanAppClip) }
      $0.appClip.state = { .deutanAppClip }
      $0.visionSimulation.cameraChangeSimulation = { _ in await didChangeCameraSimulation.setValue(true) }
    }
  )
}

private extension NSUserActivity {
  static let deutanAppClip: NSUserActivity  = {
    let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    activity.webpageURL = .deutanAppClip
    return activity
  }()
}

private extension URL {
  static let deutanAppClip = URL(string: "https://www.example.com/clip?p1=deutan")
}

extension AppClipState {
  static let deutanAppClip = AppClipState(
    appClipLaunchCount: 0,
    isFirstSessionAfterAppClip: false,
    invocations: AppClipState.Invocations(past: [], current: .loaded(.deutanAppClip))
  )
}

private class TestUserDefaults: UserDefaults {

  convenience init() {
    self.init(suiteName: "Test")!
  }

  override init?(suiteName suitename: String?) {
    UserDefaults().removePersistentDomain(forName: suitename!)
    super.init(suiteName: suitename)
  }
}
