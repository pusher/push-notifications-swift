import XCTest
import Nimble
@testable import PushNotifications

class DeviceRegistrationTests: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"

    override func setUp() {
        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    override func tearDown() {
        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    func convert(hexString: String) -> Data? {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        return data
    }

    func testStartRegisterDeviceTokenResultsInDeviceIdBeingStored() {
        let pushNotifications = PushNotifications.shared
        pushNotifications.start(instanceId: instanceId)

        let deviceTokenStatic = convert(hexString: "81f5b7dda5c66bd2497c15a79a8be6e8858f7bd62ccfbb96cbbed9d327d95a78")!

        pushNotifications.registerDeviceToken(deviceTokenStatic)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
    }
}
