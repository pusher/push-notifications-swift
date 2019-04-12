import XCTest
import Nimble
@testable import PushNotifications

class StopTests: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-StopTests".data(using: .utf8)!

    override func setUp() {
        if let deviceId = Device.getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    override func tearDown() {
        if let deviceId = Device.getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    func testStopShouldDeleteDeviceOnTheServer() {
        let pushNotifications = PushNotifications()
        pushNotifications.start(instanceId: instanceId)
        pushNotifications.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = Device.getDeviceId()!

        let exp = expectation(description: "Stop completion handler must be called")
        pushNotifications.stop {
            exp.fulfill()
        }

        expect(TestAPIClientHelper().getDevice(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(beNil(), timeout: 10)

        waitForExpectations(timeout: 1)
    }

    func testShouldDeleteLocalInterests() {
        let pushNotifications = PushNotifications()
        pushNotifications.start(instanceId: instanceId)
        pushNotifications.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)

        pushNotifications.stop { }

        XCTAssertEqual(pushNotifications.getDeviceInterests(), [])
    }

    func testAfterStopStartingAgainShouldBePossible() {
        let pushNotifications = PushNotifications()
        pushNotifications.start(instanceId: instanceId)
        pushNotifications.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)

        pushNotifications.stop { }

        expect(Device.getDeviceId()).toEventually(beNil(), timeout: 10)

        pushNotifications.start(instanceId: self.instanceId)
        pushNotifications.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
    }
}
