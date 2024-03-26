import Analytics
import Common
import ComposableArchitecture
import SwiftUI

@Reducer
package struct LearnTab {
  package init() {}

  package struct State: Codable, Equatable {
    package init() {}
  }

  package enum Action {
    case onAppear
  }

  package var body: some ReducerOf<LearnTab> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .track { .event(.viewTabLearn) }
      }
    }
  }
}

extension LearnTab {
  package struct Screen: View {
    package init(store: StoreOf<LearnTab>) {
      self.store = store
    }

    @Bindable private var store: StoreOf<LearnTab>

    package var body: some View {
      ProgressView()
        .task { store.send(.onAppear) }
    }
  }
}
