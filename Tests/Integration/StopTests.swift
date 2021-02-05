import Nimble
@testable import PushNotifications
import XCTest

class StopTests: XCTestCase {
    // Real production instance.
    private let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    private let validToken = "notadevicetoken-apns-StopTests".data(using: .utf8)!
    private let deviceStateStore = InstanceDeviceStateStore("1b880590-6301-4bb5-b34f-45db1c5f5644")

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

        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: .seconds(10))
        let deviceId = self.deviceStateStore.getDeviceId()!

        let exp = expectation(description: "Stop completion handler must be called")
        pushNotifications.stop {
            exp.fulfill()
        }

        expect(TestAPIClientHelper().getDevice(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(beNil(), timeout: .seconds(10))

        waitForExpectations(timeout: 1)
    }

    func testShouldDeleteLocalInterests() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: .seconds(10))

        pushNotifications.stop { }

        XCTAssertEqual(pushNotifications.getDeviceInterests(), [])
    }

    func testAfterStopStartingAgainShouldBePossible() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: .seconds(10))

        pushNotifications.stop { }

        expect(self.deviceStateStore.getDeviceId()).toEventually(beNil(), timeout: .seconds(10))

        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: .seconds(10))
    }
}
