import XCTest
@testable import PushNotifications

class PublishIdTests: XCTestCase {
    var userInfo: [AnyHashable: Any]!

    override func setUp() {
        self.userInfo = self.constructUserInfo()
        super.setUp()
    }

    override func tearDown() {
        self.userInfo = nil
        super.tearDown()
    }

    func testReturnsId() {
        let parsedId = PublishId(userInfo: self.userInfo).id
        XCTAssertNotNil(parsedId)
        XCTAssertEqual(parsedId, "123")
    }

    func constructUserInfo() -> [AnyHashable: Any] {
        let publishId = ["publishId": "123"]
        let pusher = ["pusher": publishId]
        let data = ["data": pusher]

        return data
    }
}
