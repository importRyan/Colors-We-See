import AppClip
import ComposableArchitecture
import SwiftUI

public final class AppDelegate: NSObject {

  public override init() {
    self.store = StoreOf<AppRoot>(
      initialState: .initialState,
      reducer: { AppRoot() },
      withDependencies: {
        $0.defaultAppStorage = .defaultSuite
      }
    )
    super.init()
  }

  init(store: StoreOf<AppRoot>) {
    self.store = store
    super.init()
  }

  let store: StoreOf<AppRoot>

  enum Action {
    case onContinue(NSUserActivity)
  }
}

extension AppDelegate {
  static func reducer() -> some ReducerOf<AppRoot> {
    Reduce { state, action in
      guard case .appDelegate(let action) = action else { return .none }
      switch action {
      case .onContinue(let activity):
        @Dependency(\.appClip.isAppClip) var isAppClip
        if isAppClip() {
          return .send(.onAppClipInvocation(activity.appClipInvocationURL))
        }
      }
      return .none
    }
  }
}

// MARK: - iOS Delegate

extension AppDelegate: UIApplicationDelegate {
  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([any UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    store.send(.appDelegate(.onContinue(userActivity)))
    return true
  }
}

// MARK: - Environment

private extension UserDefaults {
  static var defaultSuite: UserDefaults = {
    if let appGroupSuiteName = Bundle.main.object(forInfoDictionaryKey: "AppGroup") as? String,
       let appGroupSuite = UserDefaults(suiteName: appGroupSuiteName) {
      return appGroupSuite
    } else {
      return .standard
    }
  }()
}
