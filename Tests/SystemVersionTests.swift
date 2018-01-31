import XCTest
@testable import PushNotifications

class SystemVersionTests: XCTestCase {
    func testSystemVersion() {
        XCTAssertNotNil(SystemVersion.version)
    }
}
