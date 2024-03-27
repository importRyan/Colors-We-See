@testable import Common
import ComposableArchitecture
import XCTest

final class VersionCheckTests: XCTestCase {

  func testMinimum_Invalid() {
    let check = VersionCheck(minimum: "1.0.1")
    XCTAssertFalse(check.isCurrentVersionValid("1.0.0"))
    XCTAssertFalse(check.isCurrentVersionValid("0.9.8"))
    XCTAssertFalse(check.isCurrentVersionValid("0.9.1"))
    XCTAssertFalse(check.isCurrentVersionValid("0.0.1"))
  }

  func testMinimum_Valid() {
    let check = VersionCheck(minimum: "1.0.0")
    XCTAssertTrue(check.isCurrentVersionValid("1.0.0"))
    XCTAssertTrue(check.isCurrentVersionValid("1.1.0"))
    XCTAssertTrue(check.isCurrentVersionValid("1.1.1"))
    XCTAssertTrue(check.isCurrentVersionValid("2.0.0"))

    let check2 = VersionCheck(minimum: "1.0.1")
    XCTAssertTrue(check2.isCurrentVersionValid("1.0.1"))
    XCTAssertTrue(check2.isCurrentVersionValid("1.1.0"))
    XCTAssertTrue(check2.isCurrentVersionValid("1.1.1"))
    XCTAssertTrue(check2.isCurrentVersionValid("2.0.0"))
  }

  func testBlockedVersions() {
    let check = VersionCheck(
      blocked: ["1.0.1", "1.0.3"],
      minimum: "1.0.0"
    )
    XCTAssertTrue(check.isCurrentVersionValid("1.1.0"))
    XCTAssertFalse(check.isCurrentVersionValid("1.0.3"))
    XCTAssertFalse(check.isCurrentVersionValid("1.0.1"))
    XCTAssertTrue(check.isCurrentVersionValid("1.0.0"))
  }
}
