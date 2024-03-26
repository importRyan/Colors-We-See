import ComposableArchitecture
import Foundation

@DependencyClient
public struct AnalyticsClient {
  public var track: @Sendable (AnalyticsEvent) -> Void
}

extension DependencyValues {
  public var analytics: AnalyticsClient {
    get { self[AnalyticsClient.self] }
    set { self[AnalyticsClient.self] = newValue }
  }
}

public extension Effect {
  static func track(
    _ event: @escaping () -> AnalyticsEvent?,
    fileID: StaticString = #fileID,
    line: UInt = #line
  ) -> Self {
    .run(
      priority: nil,
      operation: { _ in
        if let event = event() {
          @Dependency(\.analytics) var analytics
          analytics.track(event)
        }
      },
      fileID: fileID,
      line: line
    )
  }
}
