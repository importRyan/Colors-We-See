import Foundation

public protocol FeatureFlag {
  associatedtype Value: Decodable
  static var key: String { get }
  static var defaultValue: Value { get }
}

public enum FeatureFlagRawValue {
  case bool(Bool)
  case data(Data)
  case number(NSNumber)
  case string(String)

  public enum Base {
    case bool
    case data
    case number
    case string
  }
}
