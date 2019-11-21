import XCTest
@testable import PushNotifications

class InstanceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName)?.removeObject(forKey: PersistenceConstants.UserDefaults.instanceId)
    }
    func testInstanceIdWasSaved() {
        let deviceStateStore = DeviceStateStore()
        XCTAssertNoThrow(deviceStateStore.persistInstanceId("abcd"))
        let instanceId = deviceStateStore.getInstanceId()

        XCTAssertNotNil(instanceId)
        XCTAssert("abcd" == instanceId)
    }
}
