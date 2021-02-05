@testable import PushNotifications
import XCTest

class ReasonTests: XCTestCase {
    func testReasonModel() {
        let reason = Reason(description: "abc")
        XCTAssertNotNil(reason)
        XCTAssertEqual(reason.description, "abc")
    }
}
