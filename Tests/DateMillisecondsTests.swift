import XCTest
@testable import PushNotifications

class DateMillisecondsTests: XCTestCase {
    func testMillisecondsNotNil() {
        XCTAssertNotNil(Date().milliseconds())
    }
}
