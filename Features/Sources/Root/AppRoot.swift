import Analytics
import AppClip
import Common
import ComposableArchitecture
import Tabs
import SwiftUI
import VisionSimulation
import VisionType

@Reducer
struct AppRoot {

  @ObservableState
  enum State: Codable, Equatable {
    case tab(Tabs.State)
    case bootstrap(Bootstrap.State)
    static let initialState = State.bootstrap(.initialState)
  }

  enum Action {
    case tab(Tabs.Action)
    case appDelegate(AppDelegate.Action)
    case bootstrap(Bootstrap.Action)
    case onAppClipInvocation(URL?)
    case onDeepLinkSetVisionType(VisionType)
  }

  @Dependency(\.appClip.setCurrentInvocation) var setCurrentInvocation
  @Dependency(\.visionSimulation.cameraChangeSimulation) var cameraChangeSimulation

  var body: some ReducerOf<Self> {
    Scope(
      state: \.tab,
      action: \.tab,
      child: Tabs.init
    )
    Scope(
      state: \.bootstrap,
      action: \.bootstrap,
      child: Bootstrap.init
    )
    Scope(
      state: \.self,
      action: \.self,
      child: AppDelegate.reducer
    )
    Reduce { state, action in
      switch action {

      case .bootstrap(.complete):
        state = .tab(.initialState)
        return runDeferredDeepLinks()

      case .appDelegate, .bootstrap, .tab:
        return .none

      case .onAppClipInvocation(let url):
        let isBooted = if case .tab = state { true } else { false }
        return .merge(
          .track {
            .event(.appClipInvocation)
            .property(.url, url?.absoluteString ?? "")
          },
          .run { _ in setCurrentInvocation(url) },
          isBooted ? applyAppClipLaunchContext(url) : .none
        )

      case .onDeepLinkSetVisionType(let visionType):
        // TODO: - Not yet enamored with the beta Shared API and its implicit operations vs. context or store patterns. Need to coalesce these actions when adding UGC features.
        if case .tab(let tabState) = state {
          tabState.camera.vision = visionType
          return .run { _ in
            await cameraChangeSimulation(visionType)
          }
        }
        return .none
      }
    }
  }
}

extension AppRoot {
  struct Screen: View {
    @Bindable var store: StoreOf<AppRoot>

    var body: some View {
      switch store.state {
      case .tab:
        if let store = store.scope(state: \.tab, action: \.tab) {
          Tabs.Screen(store: store)
        }
      case .bootstrap:
        if let store = store.scope(state: \.bootstrap, action: \.bootstrap) {
          Bootstrap.Screen(store: store)
        }
      }
    }
  }
}

/// Currently the only deferred deep links come from an App Clip
private func runDeferredDeepLinks() -> Effect<AppRoot.Action> {
  .run { send in
    @Dependency(\.appClip) var appClip
    if appClip.isAppClip(),
       let invocationVisionType = appClip.state().invocations.currentContext?.visionType,
       let visionType = VisionType(rawValue: invocationVisionType) {
      await send(.onDeepLinkSetVisionType(visionType))
    }
  }
}

private func applyAppClipLaunchContext(_ url: URL?) -> Effect<AppRoot.Action> {
  guard let url else { return .none }
  return .run { send in
    if let invocationVisionType = url.appClipContext.visionType,
       let visionType = VisionType(rawValue: invocationVisionType) {
      await send(.onDeepLinkSetVisionType(visionType))
    }
  }
}
