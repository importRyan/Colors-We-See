import Foundation

extension InitializationError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .gpuUnavailable:
      return String(localized: "InitializationError.gpuUnavailable.", bundle: .module)
    case .gpuCommandsUnavailable:
      return String(localized: "InitializationError.gpuCommandsUnavailable.", bundle: .module)
    }
  }
}
