import Analytics

public enum AnalyticsEventProperty: String, AnalyticsEvent.Property {
  case reason
  case simulation
  case url
  case variant
}

public extension AnalyticsEvent {
  func property(_ property: AnalyticsEventProperty, _ value: String) -> AnalyticsEvent {
    var _self = self
    _self[property] = value
    return _self
  }
}
