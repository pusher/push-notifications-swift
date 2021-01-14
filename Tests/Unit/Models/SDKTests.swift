import XCTest
@testable import PushNotifications

class SDKTests: XCTestCase {
    func testVersionModel() {
        let version = SDK.version
        XCTAssertNotNil(version)
        XCTAssertEqual(version, "3.0.4")
    }
}
