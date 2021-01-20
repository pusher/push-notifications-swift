import XCTest
@testable import PushNotifications

class DeviceTokenHelperTests: XCTestCase {

    func testConvertToString() {
        let deviceTokenString = "551c547e8dba7f13b69b00cead88e9c2adcc0a68a8659214d03de71f4b9357e2"
        let deviceTokenData = deviceTokenString.toData()! // Convert to `Data` from hexadecimal representation.
        let toDeviceTokenString = deviceTokenData.hexadecimalRepresentation() // Convert back to hexadecimal representation.
        XCTAssert(deviceTokenString == toDeviceTokenString)
    }

    func testConversionToDataIsNil() {
        let deviceTokenString = ""
        XCTAssert(deviceTokenString.toData() == nil)
    }
}
