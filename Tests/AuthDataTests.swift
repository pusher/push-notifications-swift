import XCTest
@testable import PushNotifications

class AuthDataTests: XCTestCase {

    var authData: AuthData!

    override func setUp() {
        super.setUp()
        self.authData = AuthData(headers: ["A": "B"], urlParams: ["1": "2"])
    }

    override func tearDown() {
        self.authData = nil
        super.tearDown()
    }

    func testAuthData() {
        XCTAssertNotNil(self.authData)
        XCTAssertEqual(self.authData.headers, ["A": "B"])
        XCTAssertEqual(self.authData.urlParams, ["1": "2"])
    }
}

