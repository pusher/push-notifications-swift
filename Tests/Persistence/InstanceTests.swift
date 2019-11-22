import XCTest
@testable import PushNotifications

class InstanceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName(instanceId: TestHelper.instanceId))?.removeObject(forKey: PersistenceConstants.UserDefaults.instanceId)
    }
    func testInstanceIdWasSaved() {
        let deviceStateStore = InstanceDeviceStateStore(TestHelper.instanceId)
        XCTAssertNoThrow(deviceStateStore.persistInstanceId(TestHelper.instanceId))
        let instanceId = deviceStateStore.getInstanceId()

        XCTAssertNotNil(instanceId)
        XCTAssert(TestHelper.instanceId == instanceId)
    }
}
