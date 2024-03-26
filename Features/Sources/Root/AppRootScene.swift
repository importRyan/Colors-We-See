import Analytics
import ComposableArchitecture
import SwiftUI

#if DEBUG
#Preview {
  AppRoot.Screen(store: AppDelegate().store)
}
#endif

public struct AppRootScene: Scene {

  public init(delegate: AppDelegate) {
    self.delegate = delegate
  }

  private let delegate: AppDelegate

  public var body: some Scene {
    WindowGroup {
      AppRoot.Screen(store: delegate.store)
    }
  }
}
