import ComposableArchitecture
import Foundation

extension AppClipClient: DependencyKey {
   public static var liveValue: AppClipClient {
    var currentInvocation = Loadable<URL?>.loading

    @Dependency(\.defaultAppStorage) var storage
    let pastInvocations: [URL] = {
      guard let data = storage.data(forKey: UserDefaultsKey.pastInvocations.rawValue),
            let urls = try? JSONDecoder().decode([URL].self, from: data)
      else { return [] }
      return urls
    }()
    var appClipLaunchCount: Int {
      storage.integer(forKey: UserDefaultsKey.appClipLaunchCount.rawValue)
    }
    let isAppClip = (Bundle.main.infoDictionary ?? [:])["NSAppClip"] != nil
    let didLaunchFullApp = storage.bool(forKey: UserDefaultsKey.didLaunchFullApp.rawValue)

    return AppClipClient(
      isAppClip: {
        isAppClip
      },
      state: {
        AppClipState(
          appClipLaunchCount: appClipLaunchCount,
          isFirstSessionAfterAppClip: {
            if isAppClip { return false }
            if appClipLaunchCount == 0 { return false }
            if didLaunchFullApp { return false }
            return true
          }(),
          invocations: .init(past: pastInvocations, current: currentInvocation)
        )
      },
      setCurrentInvocation: { url in
        guard isAppClip else { return }
        currentInvocation = .loaded(url)
        if let url {
          var past = pastInvocations
          past.append(url)
          storage.set(past, forKey: UserDefaultsKey.pastInvocations.rawValue)
        }
      },
      markLaunch: {
        if isAppClip {
          let lastCount = appClipLaunchCount
          storage.set(lastCount + 1, forKey: UserDefaultsKey.appClipLaunchCount.rawValue)
        } else {
          storage.set(true, forKey: UserDefaultsKey.didLaunchFullApp.rawValue)
        }
      }
    )
  }
}

private enum UserDefaultsKey: String {
  case appClipLaunchCount
  case didLaunchFullApp
  case pastInvocations
}
