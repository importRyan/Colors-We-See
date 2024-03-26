import Foundation

public extension NSUserActivity {
  var appClipInvocationURL: URL? {
    guard activityType == NSUserActivityTypeBrowsingWeb else { return nil }
    return webpageURL
  }
}
