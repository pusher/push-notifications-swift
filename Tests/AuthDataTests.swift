import XCTest
@testable import PushNotifications

class AuthDataTests: XCTestCase {

    var authData: AuthData!

    override func setUp() {
        super.setUp()
        self.authData = AuthData(headers: ["A": "B"], queryParams: ["1": "2"])
    }

    override func tearDown() {
        self.authData = nil
        super.tearDown()
    }

    func testAuthData() {
        XCTAssertNotNil(self.authData)
        XCTAssertEqual(self.authData.headers, ["A": "B"])
        XCTAssertEqual(self.authData.queryParams, ["1": "2"])
    }
}

