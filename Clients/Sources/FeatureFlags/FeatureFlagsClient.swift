import ComposableArchitecture
import Foundation

@DependencyClient
public struct FeatureFlagsClient {
  public var hydrate: () async throws -> Void
  public var rawValue: (any FeatureFlag.Type) -> FeatureFlagRawValue?
}

public extension FeatureFlagsClient {

  func value<Flag: FeatureFlag>(for flag: Flag.Type) throws -> Flag.Value {
    try value(for: flag) ?? flag.defaultValue
  }

  private func value<Flag: FeatureFlag>(for flag: Flag.Type) throws -> Flag.Value? {
    switch rawValue(flag) {
    case .bool(let value):
      return value as? Flag.Value

    case .data(let data):
      if Value.self == Data.self { return data as? Flag.Value }
      do {
        return try JSONDecoder().decode(Flag.Value.self, from: data)
      } catch {
        if data.isEmpty || data == Data(#""""#.utf8) { return nil }
        throw error
      }

    case .number(let value):
      if let value = value as? Flag.Value { return value }
      if let value = value.doubleValue as? Flag.Value { return value }
      if let value = value.decimalValue as? Flag.Value { return value }
      if let value = value.intValue as? Flag.Value { return value }
      if let value = value.floatValue as? Flag.Value { return value }
      throw FeatureFlagError.unknownType

    case .string(let string):
      return string as? Flag.Value
      
    case .none:
      return .none
    }
  }
}

extension DependencyValues {
  public var featureFlags: FeatureFlagsClient {
    get { self[FeatureFlagsClient.self] }
    set { self[FeatureFlagsClient.self] = newValue }
  }
}

public enum FeatureFlagError: Error {
  case unknownType
}
