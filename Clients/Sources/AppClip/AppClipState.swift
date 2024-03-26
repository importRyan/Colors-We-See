import Foundation

public struct AppClipState {
  public let appClipLaunchCount: Int
  public let isFirstSessionAfterAppClip: Bool
  public let invocations: Invocations

  /// App Clip launches might include an invocation URL. Apple [encourages hydrating past context](https://developer.apple.com/documentation/app_clips/responding_to_invocations#3730260).
  public struct Invocations {
    public let past: [URL]
    public let current: Loadable<URL?>

    public var bestKnown: Loadable<URL?> {
      return switch current {
      case .loading:
          .loaded(past.last)
      case .loaded(let url):
        if url == nil { .loaded(past.last) } else { current }
      }
    }

    public var currentContext: URL.AppClipContext? {
      guard let current = current.value else { return nil }
      return current?.appClipContext
    }
  }

  static let initialState = AppClipState(
    appClipLaunchCount: 0,
    isFirstSessionAfterAppClip: false,
    invocations: Invocations(past: [], current: .loading)
  )
}

public enum Loadable<V> {
  case loading
  case loaded(V)

  public var value: V? {
    switch self {
    case .loading: return nil
    case .loaded(let value): return value
    }
  }
}
