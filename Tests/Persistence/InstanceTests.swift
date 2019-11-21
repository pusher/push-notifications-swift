import XCTest
@testable import PushNotifications

class InstanceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName)?.removeObject(forKey: PersistenceConstants.UserDefaults.instanceId)
    }
    func testInstanceIdWasSaved() {
        XCTAssertNoThrow(Instance.persist("abcd"))
        let instanceId = Instance.getInstanceId()

        XCTAssertNotNil(instanceId)
        XCTAssert("abcd" == instanceId)
    }
}
