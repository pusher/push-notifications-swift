import XCTest
@testable import PushNotifications

class UserIdTests: XCTestCase {

    func testReturnsUserId() {
        let userInfo = self.constructUserInfo()
        let parsedUserId = UserId(userInfo: userInfo).id
        XCTAssertNotNil(parsedUserId)
        XCTAssertEqual(parsedUserId, "123")
    }

    func testReturnsNil() {
        let userInfo = self.constructNilUserIdUserInfo()
        let parsedUserId = UserId(userInfo: userInfo).id
        XCTAssertNil(parsedUserId)
        XCTAssertEqual(parsedUserId, nil)
    }

    func constructUserInfo() -> [AnyHashable: Any] {
        let userId = ["userId": "123"]
        let pusher = ["pusher": userId]
        let data = ["data": pusher]

        return data
    }

    func constructNilUserIdUserInfo() -> [AnyHashable: Any] {
        let userId = ["userId": nil] as [String : Any?]
        let pusher = ["pusher": userId]
        let data = ["data": pusher]

        return data
    }
}
