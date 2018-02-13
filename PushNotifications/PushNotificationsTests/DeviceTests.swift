import XCTest
@testable import PushNotifications

class DeviceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Device.persist("abcd")
    }

    override func tearDown() {
        UserDefaults(suiteName: "PushNotifications")?.removeObject(forKey: "com.pusher.sdk.deviceId")
        super.tearDown()
    }

    func testPersist() {
        let deviceId = Device.getDeviceId()

        XCTAssertNotNil(deviceId)
        XCTAssert("abcd" == deviceId)
    }
}

