import ComposableArchitecture
import FirebaseAnalytics

extension AnalyticsClient: DependencyKey {
  public static var liveValue: AnalyticsClient {
    return AnalyticsClient(
      track: { event in
        Analytics.logEvent(event.name.rawValue, parameters: event.properties)
      }
    )
  }
}
