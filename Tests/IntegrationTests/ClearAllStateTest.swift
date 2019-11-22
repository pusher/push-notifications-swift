import XCTest
import Nimble
@testable import PushNotifications

class ClearAllStateTest: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-ClearAllStateTest".data(using: .utf8)!

    override func setUp() {
        TestHelper().setUpDeviceId(instanceId: instanceId)

        UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName(instanceId: nil)).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }

        TestHelper().removeSyncjobStore()
    }

    override func tearDown() {
        TestHelper().tearDownDeviceId(instanceId: instanceId)

        UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName(instanceId: nil)).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }

        TestHelper().removeSyncjobStore()
    }

    func testItShouldClearAllState() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        let deviceStateStore = InstanceDeviceStateStore(self.instanceId)
        expect(deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = deviceStateStore.getDeviceId()

        XCTAssertNoThrow(try pushNotifications.addDeviceInterest(interest: "a"))
        XCTAssertEqual(pushNotifications.getDeviceInterests(), ["a"])
        let exp = expectation(description: "Clear all state completion handler must be called")
        pushNotifications.clearAllState {
            exp.fulfill()
        }

        expect(TestAPIClientHelper().getDevice(instanceId: self.instanceId, deviceId: deviceId!))
            .toEventually(beNil(), timeout: 10)

        XCTAssertEqual(pushNotifications.getDeviceInterests(), [])
        expect(InstanceDeviceStateStore(self.instanceId).getDeviceId()).toEventuallyNot(equal(deviceId!), timeout: 10)

        waitForExpectations(timeout: 1)
    }
}
