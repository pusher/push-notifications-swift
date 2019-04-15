import XCTest
import Nimble
@testable import PushNotifications

class ApplicationStartTests: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-ApplicationStartTests".data(using: .utf8)!

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

    func testApplicationStartWillSyncInterests() {
        let pushNotifications = PushNotifications.shared
        pushNotifications.start(instanceId: instanceId)

        pushNotifications.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = Device.getDeviceId()!

        expect(TestAPIClientHelper().getDeviceInterests(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(equal([]), timeout: 10)

        DeviceStateStore.interestsService.persist(interests: ["cucas", "panda", "potato"])
        pushNotifications.start(instanceId: instanceId)

        expect(TestAPIClientHelper().getDeviceInterests(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(contain("cucas", "panda", "potato"), timeout: 10)
    }
}

