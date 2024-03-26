import Analytics
import AppClip
import Common
import ComposableArchitecture
import StoreKit
import SwiftUI

@Reducer
package struct AppClipFullAppDownload {

  @ObservableState
  package struct State: Codable, Equatable {
    var showDownloadPrompt = false
    var showAppClipStoreKitOverlay = false
  }

  package enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case revealDownloadPrompt
  }

  @Dependency(\.appClip.isAppClip) var isAppClip

  package var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.showAppClipStoreKitOverlay):
        return .track { [isPresented = state.showAppClipStoreKitOverlay] in
          .event(
            isPresented
            ? .appClipStoreKitOverlayPresented
            : .appClipStoreKitOverlayDismissed
          )
        }

      case .revealDownloadPrompt:
        guard isAppClip() else { return .none }
        if state.showDownloadPrompt { return .none }
        state.showDownloadPrompt = true
        return .track { .event(.appClipStoreKitDownloadPromptPresented) }

      default:
        return .none
      }
    }
  }
}

extension AppClipFullAppDownload {
  struct Button: View {
    @Bindable var store: StoreOf<AppClipFullAppDownload>

    var body: some View {
      if store.showDownloadPrompt {
        SwiftUI.Button(
          action: { store.send(.binding(.set(\.showAppClipStoreKitOverlay, true))) },
          label: { Text(.AppClip.getAppCTA) }
        )
        .appStoreOverlay(isPresented: $store.showAppClipStoreKitOverlay) {
          SKOverlay.AppClipConfiguration(position: .bottom)
        }
        .transition(.blurReplace(.downUp).animation(.smooth))
      }
    }
  }
}
