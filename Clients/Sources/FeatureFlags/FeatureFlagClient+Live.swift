import ComposableArchitecture
import FirebaseRemoteConfig
import Foundation

extension FeatureFlagsClient: DependencyKey {
  public static var liveValue: FeatureFlagsClient {
    let firebase = RemoteConfig.remoteConfig()
    return FeatureFlagsClient(
      hydrate: {
        let settings = RemoteConfigSettings()
#if DEBUG
        settings.minimumFetchInterval = 0
#else
        settings.minimumFetchInterval = 900
#endif
        firebase.configSettings = settings
        try await firebase.fetchAndActivate()
      },
      rawValue: { flag in
        let base: FeatureFlagRawValue.Base = if flag.defaultValue is Bool { .bool }
        else if flag.defaultValue is String { .string }
        else if flag.defaultValue is Double { .number }
        else if flag.defaultValue is Int { .number }
        else { .data }

        let value = firebase.configValue(forKey: flag.key)

        return switch base {
        case .bool: .bool(value.boolValue)
        case .data: .data(value.dataValue)
        case .number: .number(value.numberValue)
        case .string: .string(value.stringValue ?? "")
        }
      }
    )
  }
}
