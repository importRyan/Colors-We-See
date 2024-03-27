import Foundation
import FeatureFlags

package struct VersionCheck: Codable {
  package let blocked: Set<String>
  package let minimum: String
  package let prompt: String?

  package init(blocked: Set<String> = [], minimum: String, prompt: String? = nil) {
    self.blocked = blocked
    self.minimum = minimum
    self.prompt = prompt
  }

  package func isCurrentVersionValid(_ currentVersion: String?) -> Bool {
    guard let currentVersion else { return false }
    if blocked.contains(currentVersion) { return false }
    if minimum == currentVersion { return true }
    return minimum.compare(currentVersion, options: .numeric) == .orderedAscending
  }
}

package extension VersionCheck {
  struct Flag: FeatureFlag {
    package static let key = "version"
    package static let defaultValue = VersionCheck(minimum: "0.0.0")
  }
}
