import VisionType
import XCTest
@testable import AppClip

final class AppClipTests: XCTestCase {
  func testParsesVisionType() throws {
    for visionType in VisionType.allCases {
      let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
      activity.webpageURL = URL(string: "https://www.example.com/clip?p1=\(visionType.rawValue)")

      let context = try XCTUnwrap(activity.appClipInvocationURL?.appClipContext)
      let rawVisionType = try XCTUnwrap(context.visionType)
      let visionType = try XCTUnwrap(VisionType(rawValue: rawVisionType))
      XCTAssertEqual(visionType, visionType)
    }
  }

  func testParsesVanillaInvocation() throws {
    let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
    activity.webpageURL = URL(string: "https://www.example.com/clip")

    let context = try XCTUnwrap(activity.appClipInvocationURL?.appClipContext)
    XCTAssertNil(context.visionType)
  }
}
