#if os(OSX)
import XCTest
@testable import PushNotifications

class RegisterTests: XCTestCase {

    let register = Register(token: "123", instanceId: "abc", bundleIdentifier: "com.pusher", metadata: Metadata(sdkVersion: "0.4.0", iosVersion: nil, macosVersion: "10.9"))

    func testRegisterModel() {
    let register = self.register
    XCTAssertNotNil(register)
    XCTAssertEqual(register.token, "123")
    XCTAssertEqual(register.instanceId, "abc")
    XCTAssertEqual(register.bundleIdentifier, "com.pusher")
    XCTAssertEqual(register.metadata.sdkVersion, "0.4.0")
    XCTAssertEqual(register.metadata.iosVersion, nil)
    XCTAssertEqual(register.metadata.macosVersion, "10.9")
    }

    func testRegisterEncoded() {
    let registerEncoded = try! self.register.encode()
    XCTAssertNotNil(registerEncoded)
    let registerJSONExpected = "{\"metadata\":{\"sdkVersion\":\"0.4.0\",\"macosVersion\":\"10.9\"},\"instanceId\":\"abc\",\"token\":\"123\",\"bundleIdentifier\":\"com.pusher\"}"
    let registerJSON = String(data: registerEncoded, encoding: .utf8)!
    XCTAssertEqual(registerJSONExpected, registerJSON)
    }
}
#endif
