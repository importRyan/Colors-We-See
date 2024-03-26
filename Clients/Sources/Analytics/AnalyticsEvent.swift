import Foundation

public struct AnalyticsEvent: Sendable {
  public protocol Name: RawRepresentable<String>, Sendable, Equatable {}
  public protocol Property: RawRepresentable<String>, Sendable, Equatable {}
  
  public let name: any Name
  public var properties: [String: String] = [:]

  public init(name: any Name) {
    self.name = name
  }
}

public extension AnalyticsEvent {
  static func event<N: Name>(_ name: N) -> Self {
    Self(name: name)
  }

  static func event<N: Name>(_ name: N?) -> Self? {
    guard let name else { return nil }
    return Self(name: name)
  }

  subscript<P: Property>(property: P) -> String? {
    get { properties[property.rawValue] }
    set {
      if let newValue {
        properties[property.rawValue] = newValue
      } else {
        properties.removeValue(forKey: property.rawValue)
      }
    }
  }

  func property<P: Property>(_ property: P, _ value: String) -> AnalyticsEvent {
    var _self = self
    _self[property] = value
    return _self
  }
}
