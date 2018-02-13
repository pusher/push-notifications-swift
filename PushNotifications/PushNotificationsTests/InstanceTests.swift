import XCTest
@testable import PushNotifications

class InstanceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        XCTAssertNoThrow(try Instance.persist("abcd"))
    }

    override func tearDown() {
        UserDefaults(suiteName: "PushNotifications")?.removeObject(forKey: "com.pusher.sdk.instanceId")
        super.tearDown()
    }

    func testInstanceIdWasSaved() {
        let instanceId = Instance.getInstanceId()

        XCTAssertNotNil(instanceId)
        XCTAssert("abcd" == instanceId)
    }

    func testPersistNewInstanceId() {
        XCTAssertThrowsError(try Instance.persist("abcdefg")) { error in
            guard case PusherAlreadyRegisteredError.instanceId(let errorMessage) = error else {
                return XCTFail()
            }

            let expectedErrorMessage = """
This device has already been registered with Pusher.
Push Notifications application with instance id: abcd.
If you would like to register this device to abcdefg please reinstall the application.
"""
            XCTAssertEqual(errorMessage, expectedErrorMessage)
        }
    }
}
