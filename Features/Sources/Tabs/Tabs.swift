import ComposableArchitecture
import CameraTab
import LearnTab
import PhotosTab
import SwiftUI

@Reducer
package struct Tabs {

  package init() {}

  enum Tab: Codable {
    case camera
    case learn
    case photos
  }

  @ObservableState
  package struct State: Codable, Equatable {
    var tab = Tab.camera
    package var camera = CameraTab.State(vision: .typical)
    var learn = LearnTab.State()
    var photos = PhotosTab.State()

    package static let initialState = State()
  }

  package enum Action: BindableAction {
    case binding(BindingAction<State>)
    case camera(CameraTab.Action)
    case learn(LearnTab.Action)
    case photos(PhotosTab.Action)
  }

  package var body: some ReducerOf<Tabs> {
    BindingReducer()
    Scope(
      state: \.camera,
      action: \.camera,
      child: CameraTab.init
    )
    Scope(
      state: \.learn,
      action: \.learn,
      child: LearnTab.init
    )
    Scope(
      state: \.photos,
      action: \.photos,
      child: PhotosTab.init
    )
  }
}

package extension Tabs {
  struct Screen: View {

    package init(store: StoreOf<Tabs>) {
      self.store = store
    }

    @Bindable private var store: StoreOf<Tabs>

    package var body: some View {
      CameraTab.Screen(store: store.scope(state: \.camera, action: \.camera))
    }
  }
}
