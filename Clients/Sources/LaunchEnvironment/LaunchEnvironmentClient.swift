import Foundation
import ComposableArchitecture

@DependencyClient
public struct LaunchEnvironmentClient {
  public var currentVersion: () -> String?
  public var value: (String) -> Any?
}

extension DependencyValues {
  public var launchEnvironment: LaunchEnvironmentClient {
    get { self[LaunchEnvironmentClient.self] }
    set { self[LaunchEnvironmentClient.self] = newValue }
  }
}

extension LaunchEnvironmentClient: DependencyKey {
  public static var liveValue: LaunchEnvironmentClient {
    LaunchEnvironmentClient(
      currentVersion: {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
      },
      value: { key in
        Bundle.main.infoDictionary?[key]
      }
    )
  }
}
