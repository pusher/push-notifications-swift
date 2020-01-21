import XCTest
import Nimble
@testable import PushNotifications

class ApplicationStartTests: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-ApplicationStartTests".data(using: .utf8)!

    override func setUp() {
        super.setUp()
        TestHelper.clearEverything(instanceId: instanceId)
    }

    override func tearDown() {
        TestHelper.clearEverything(instanceId: instanceId)
        super.tearDown()
    }

    func testApplicationStartWillSyncInterests() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()

        pushNotifications.registerDeviceToken(validToken)

        let deviceStateStore = InstanceDeviceStateStore(self.instanceId)
        expect(deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = deviceStateStore.getDeviceId()!

        expect(TestAPIClientHelper().getDeviceInterests(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(equal([]), timeout: 10)

        _ = InstanceDeviceStateStore(self.instanceId).persistInterests(["cucas", "panda", "potato"])
        pushNotifications.start()

        expect(TestAPIClientHelper().getDeviceInterests(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(contain("cucas", "panda", "potato"), timeout: 10)
    }
}

