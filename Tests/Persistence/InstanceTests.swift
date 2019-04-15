import XCTest
@testable import PushNotifications

class InstanceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.removeObject(forKey: Constants.UserDefaults.instanceId)
    }
    func testInstanceIdWasSaved() {
        XCTAssertNoThrow(Instance.persist("abcd"))
        let instanceId = Instance.getInstanceId()

        XCTAssertNotNil(instanceId)
        XCTAssert("abcd" == instanceId)
    }
}
