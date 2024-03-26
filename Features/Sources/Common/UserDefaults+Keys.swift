import ComposableArchitecture
import Foundation
import VisionType

extension UserDefaults {
  enum Keys: String {
    case vision
  }
}

public extension PersistenceKey where Self == AppStorageKey<VisionType> {
  static var visionType: AppStorageKey<VisionType> {
    .appStorage(UserDefaults.Keys.vision.rawValue)
  }
}
