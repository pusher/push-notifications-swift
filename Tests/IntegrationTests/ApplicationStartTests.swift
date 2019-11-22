import XCTest
import Nimble
@testable import PushNotifications

class ApplicationStartTests: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-ApplicationStartTests".data(using: .utf8)!

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

    func testApplicationStartWillSyncInterests() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()

        pushNotifications.registerDeviceToken(validToken)

        let deviceStateStore = DeviceStateStore()
        expect(deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = deviceStateStore.getDeviceId()!

        expect(TestAPIClientHelper().getDeviceInterests(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(equal([]), timeout: 10)

        DeviceStateStore().persistInterests(["cucas", "panda", "potato"])
        pushNotifications.start()

        expect(TestAPIClientHelper().getDeviceInterests(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(contain("cucas", "panda", "potato"), timeout: 10)
    }
}

