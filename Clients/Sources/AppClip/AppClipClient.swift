import ComposableArchitecture
import Foundation

@DependencyClient
public struct AppClipClient {
  public var isAppClip: () -> Bool = { false }
  public var state: () -> AppClipState = { .initialState }
  public var setCurrentInvocation: (URL?) -> Void
  public var markLaunch: () -> Void
}

extension DependencyValues {
  public var appClip: AppClipClient {
    get { self[AppClipClient.self] }
    set { self[AppClipClient.self] = newValue }
  }
}
