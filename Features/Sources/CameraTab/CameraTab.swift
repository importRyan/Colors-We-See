import Analytics
import Common
import ComposableArchitecture
import SwiftUI
import VisionSimulation
import VisionType

@Reducer
package struct CameraTab {
  package init() {}

  @ObservableState
  package struct State: Codable, Equatable {
    var appClip: AppClipFullAppDownload.State
    var camera: Camera.State
    @Shared package var vision: VisionType

    package init(camera: Camera.State = .initialState, vision: @autoclosure () -> VisionType) {
      self._vision = .init(wrappedValue: vision(), .visionType)
      self.camera = camera
      self.appClip = .init()
    }

    // TODO: - @Shared temporarily ditched Decodable conformance for sensical reasons during beta; revisit.
    package init(from decoder: any Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.camera = try container.decode(Camera.State.self, forKey: ._camera)
      self.appClip = try container.decode(AppClipFullAppDownload.State.self, forKey: ._appClip)
      let value = try container.decode(VisionType.self, forKey: .vision)
      self._vision = .init(wrappedValue: value, .visionType)
    }
  }

  package enum Action: BindableAction, Equatable {
    case onAppear
    case appClip(AppClipFullAppDownload.Action)
    case camera(Camera.Action)
    case binding(BindingAction<State>)
  }

  @Dependency(\.visionSimulation) var visionSimulation
  @Dependency(\.suspendingClock) var clock

  package var body: some ReducerOf<CameraTab> {
    BindingReducer()
    Scope(
      state: \.camera,
      action: \.camera,
      child: Camera.init
    )
    Scope(
      state: \.appClip,
      action: \.appClip,
      child: AppClipFullAppDownload.init
    )
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .track { .event(.viewTabCamera) }

      case .appClip:
        return .none

      case .camera(.startCameraResult(.success)):
        return .run { send in
          try await clock.sleep(for: .seconds(8))
          await send(.appClip(.revealDownloadPrompt))
        }

      case .camera:
        return .none

      case .binding(\.vision):
        let vision = state.vision
        return .merge(
          .run { send in
            await visionSimulation.cameraChangeSimulation(vision)
            try await clock.sleep(for: .seconds(4))
            await send(.appClip(.revealDownloadPrompt))
          },
          .track {
            .event(.changeVisionSimulationTapped)
            .property(.simulation, vision.rawValue)
          }
        )

      case .binding:
        return .none
      }
    }
  }
}

extension CameraTab {
  package struct Screen: View {
    package init(store: StoreOf<CameraTab>) {
      self.store = store
    }

    @Bindable private var store: StoreOf<CameraTab>

    package var body: some View {
      ZStack(alignment: .bottom) {
        Camera.FeedView(store: store.scope(state: \.camera, action: \.camera))
        
        if store.camera == .streaming {
          CameraSimulationPicker(simulation: $store.vision)
            .scenePadding()
            .padding(.bottom, 60)
            .transition(.scale.combined(with: .opacity).animation(.bouncy))

          AppClipFullAppDownload.Button(store: store.scope(state: \.appClip, action: \.appClip))
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            .foregroundStyle(.secondary)
            .scenePadding()
        }
      }
      .onAppear { store.send(.onAppear) }
    }
  }
}
