import Common
import ComposableArchitecture
import XCTest
@testable import Root

final class BootstrapTests: XCTestCase {

  @MainActor
  func testFeatureFlagHydrationFails_AppCanStart() async {
    let store = TestStore(
      initialState: Bootstrap.State.initialState,
      reducer: Bootstrap.init,
      withDependencies: {
        $0.analytics.track = { _ in }
        $0.appClip.markLaunch = { }
        $0.featureFlags.hydrate = { }
        $0.featureFlags.rawValue = { _ in .none }
        $0.launchEnvironment.currentVersion = { "100.0.0" }
        $0.visionSimulation.initialize = { _ in }
      }
    )
    await store.send(.boot)
    await store.receive(.complete)
  }

  @MainActor
  func testInvalidVersion_ShowsUpdateScreen() async throws {
    let versionCheck = try JSONEncoder().encode(VersionCheck(blocked: ["100.0.0"], minimum: "1.0.0"))
    let store = TestStore(
      initialState: Bootstrap.State.initialState,
      reducer: Bootstrap.init,
      withDependencies: {
        $0.analytics.track = { _ in }
        $0.appClip.markLaunch = { }
        $0.featureFlags.hydrate = { }
        $0.featureFlags.rawValue = { flag in
          flag.defaultValue is VersionCheck ? .data(versionCheck) : .none 
        }
        $0.launchEnvironment.currentVersion = { "100.0.0" }
        $0.visionSimulation.initialize = { _ in }
      }
    )
    store.exhaustivity = .off
    await store.send(.boot)
    await store.receive(.updateRequired(reason: nil))
  }
}
