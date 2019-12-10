import XCTest
import Nimble
@testable import PushNotifications

class DeviceRegistrationTests: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-DeviceRegistrationTests".data(using: .utf8)!

    override func setUp() {
        super.setUp()
        TestHelper.clearEverything(instanceId: instanceId)
    }

    override func tearDown() {
        TestHelper.clearEverything(instanceId: instanceId)
        super.tearDown()
    }

    func testStartRegisterDeviceTokenResultsInDeviceIdBeingStored() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()

        pushNotifications.registerDeviceToken(validToken)

        expect(InstanceDeviceStateStore(self.instanceId).getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
    }
}
