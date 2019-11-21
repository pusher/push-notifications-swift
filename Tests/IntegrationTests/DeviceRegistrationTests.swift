import XCTest
import Nimble
@testable import PushNotifications

class DeviceRegistrationTests: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-DeviceRegistrationTests".data(using: .utf8)!

    override func setUp() {
        TestHelper().setUpDeviceId(instanceId: instanceId)

        UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }

        TestHelper().removeSyncjobStore()
    }

    override func tearDown() {
        TestHelper().tearDownDeviceId(instanceId: instanceId)

        UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }

        TestHelper().removeSyncjobStore()
    }

    func testStartRegisterDeviceTokenResultsInDeviceIdBeingStored() {
        let pushNotifications = PushNotifications.shared
        pushNotifications.start(instanceId: instanceId)

        pushNotifications.registerDeviceToken(validToken)

        expect(DeviceStateStore().getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
    }
}
