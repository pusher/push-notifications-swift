import XCTest
@testable import PushNotifications

class DeviceTests: XCTestCase {
    func testPersist() {
        let deviceStateStore = InstanceDeviceStateStore(nil)
        deviceStateStore.persistDeviceId("abcd")
        let deviceId = deviceStateStore.getDeviceId()

        XCTAssertNotNil(deviceId)
        XCTAssert("abcd" == deviceId)
    }
}
