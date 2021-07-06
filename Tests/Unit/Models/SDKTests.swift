@testable import PushNotifications
import XCTest

class SDKTests: XCTestCase {
    func testVersionModel() {
        let version = SDK.version
        XCTAssertNotNil(version)
        XCTAssertEqual(version, "4.0.0")
    }
}
