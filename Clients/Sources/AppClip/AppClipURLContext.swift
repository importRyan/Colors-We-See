import Foundation

public extension URL {

  var appClipContext: AppClipContext {
    AppClipContext(url: self)
  }

  struct AppClipContext {
    public let visionType: String?

    public init(url: URL) {
      let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
      visionType = queryItems.first(where: { $0.name == Keys.visionType.rawValue })?.value
    }
  }
}

extension URL.AppClipContext {
  enum Keys: String {
    case visionType = "p1"
  }
}
