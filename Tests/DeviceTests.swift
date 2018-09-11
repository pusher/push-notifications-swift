import XCTest
@testable import PushNotifications

class DeviceTests: XCTestCase {
    func testPersist() {
        Device.persist(deviceId: "abcd")
        let deviceId = Device.getDeviceId()

        XCTAssertNotNil(deviceId)
        XCTAssert("abcd" == deviceId)
    }
}
