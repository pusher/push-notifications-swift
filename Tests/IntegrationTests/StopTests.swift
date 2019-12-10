import XCTest
import Nimble
@testable import PushNotifications

class StopTests: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-StopTests".data(using: .utf8)!
    let deviceStateStore = InstanceDeviceStateStore("1b880590-6301-4bb5-b34f-45db1c5f5644")

    override func setUp() {
        super.setUp()
        TestHelper.clearEverything(instanceId: instanceId)
    }

    override func tearDown() {
        TestHelper.clearEverything(instanceId: instanceId)
        super.tearDown()
    }

    func testStopShouldDeleteDeviceOnTheServer() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = self.deviceStateStore.getDeviceId()!

        let exp = expectation(description: "Stop completion handler must be called")
        pushNotifications.stop {
            exp.fulfill()
        }

        expect(TestAPIClientHelper().getDevice(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(beNil(), timeout: 10)

        waitForExpectations(timeout: 1)
    }

    func testShouldDeleteLocalInterests() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)

        pushNotifications.stop { }

        XCTAssertEqual(pushNotifications.getDeviceInterests(), [])
    }

    func testAfterStopStartingAgainShouldBePossible() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)

        pushNotifications.stop { }

        expect(self.deviceStateStore.getDeviceId()).toEventually(beNil(), timeout: 10)

        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
    }
}
