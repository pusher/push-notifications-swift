import XCTest
@testable import PushNotifications

class PushNotificationsRegisterableTests: XCTestCase {

    func testRegistration() {
        let pushNotificationsRegisterable: PushNotificationsRegisterable = MockPushNotificationsRegisterable()
        pushNotificationsRegisterable.register(deviceToken: Data()) { (deviceId) in
            XCTAssert(deviceId == "apns-876eeb5d-0dc8-4d74-9f59-b65412b2c742")
        }
    }
}
