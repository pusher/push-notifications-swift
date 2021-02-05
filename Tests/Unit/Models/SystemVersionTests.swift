@testable import PushNotifications
import XCTest

class SystemVersionTests: XCTestCase {
    func testSystemVersion() {
        XCTAssertNotNil(SystemVersion.version)
    }
}
