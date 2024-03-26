import Analytics
import Common
import ComposableArchitecture
import SwiftUI

@Reducer
package struct PhotosTab {
  package init() {}

  package struct State: Codable, Equatable {
    package init() {}
  }

  package enum Action {
    case onAppear
  }

  package var body: some ReducerOf<PhotosTab> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .track { .event(.viewTabPhotos) }
      }
    }
  }
}

extension PhotosTab {
  package struct Screen: View {
    package init(store: StoreOf<PhotosTab>) {
      self.store = store
    }

    @Bindable private var store: StoreOf<PhotosTab>

    package var body: some View {
      ProgressView()
        .task { store.send(.onAppear) }
    }
  }
}
