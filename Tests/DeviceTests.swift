import XCTest
@testable import PushNotifications

class DeviceTests: XCTestCase {
    func testPersist() {
        Device.persist(deviceId: "abcd")
        let deviceId = Device.getDeviceId()

        XCTAssertNotNil(deviceId)
        XCTAssert("abcd" == deviceId)
        XCTAssertTrue(Device.idAlreadyPresent())
    }

    func testPersistDeviceToken() {
        let deviceToken = "abcd"
        UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.removeObject(forKey: Constants.UserDefaults.deviceToken)
        XCTAssertTrue(Device.tokenHasChanged(deviceToken: deviceToken))
        Device.persist(deviceToken: deviceToken)
        XCTAssertFalse(Device.tokenHasChanged(deviceToken: deviceToken))
        XCTAssertTrue(Device.tokenHasChanged(deviceToken: "1234"))
    }
}
