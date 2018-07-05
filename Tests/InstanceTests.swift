import XCTest
@testable import PushNotifications

class InstanceTests: XCTestCase {
    func testInstanceIdWasSaved() {
        XCTAssertNoThrow(try Instance.persist("abcd"))
        let instanceId = Instance.getInstanceId()

        XCTAssertNotNil(instanceId)
        XCTAssert("abcd" == instanceId)
    }

    func testPersistNewInstanceId() {
        XCTAssertNoThrow(try Instance.persist("abcd"))
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
