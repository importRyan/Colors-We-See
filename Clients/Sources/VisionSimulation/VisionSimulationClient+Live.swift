import AsyncAlgorithms
import ComposableArchitecture
import MetalKit
import VisionType

extension VisionSimulationClient {
  public static let live = {
    let errors = AsyncChannel<Error>()
    return Self.init(
      initialize: { initialSimulation in
        try initializeInternalSingletons(
          with: initialSimulation,
          errors: errors
        )
      },
      cameraAuthorize: {
        await AVCameraCapture.authorize()
      },
      cameraAuthorizationStatus: {
        AVCameraCapture.currentAuthorizationStatus()
      },
      cameraStart: {
        do {
          let result = try await camera.startCamera()
          return .success(result)
        } catch {
          return .failure((error as? CameraError) ?? CameraError.unknown)
        }
      },
      cameraRestart: {
        camera.restartCamera()
      },
      cameraStop: {
        camera.stopCamera()
      },
      cameraChangeSimulation: { newSimulation in
        metal?.dispatchQueue.sync {
          metal?.realtimeFilter = newSimulation
        }
      },
      errors: {
        errors
      },
      computeSimulations: { cgImage in
        try await metal.computeSimulations(for: cgImage)
      }
    )
  }()
}


// MARK: - Initialize Module Singleton

fileprivate(set) var camera: AVCameraCapture!
fileprivate(set) var metal: MetalAssetStore!

private func initializeInternalSingletons(
  with initialSimulation: VisionType,
  errors: AsyncChannel<Error>
) throws {
  let queue = DispatchQueue(
    label: "\(Bundle.main.bundleIdentifier ?? "").visionSimulation",
    qos: .userInteractive
  )

  metal = try .init(
    initialSimulation: initialSimulation,
    queue: queue
  )

  camera = .init(
    queue: queue,
    didCaptureFrame: { buffer in
      do {
        try metal.getRealtimeTexture(fromCapturedFrame: buffer)
      } catch {
        Task { await errors.send(error) }
      }
    }
  )
}
