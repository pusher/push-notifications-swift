import XCTest
@testable import PushNotifications

class ReasonTests: XCTestCase {
    func testReasonModel() {
        let reason = Reason(description: "abc")
        XCTAssertNotNil(reason)
        XCTAssertEqual(reason.description, "abc")
    }
}
