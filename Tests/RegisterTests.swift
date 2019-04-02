import XCTest
@testable import PushNotifications

class RegisterTests: XCTestCase {
    #if os(iOS)
    let register = Register(token: "123", bundleIdentifier: "com.pusher", metadata: Metadata(sdkVersion: "0.4.0", iosVersion: "11.2.0", macosVersion: nil))
    #elseif os(OSX)
    let register = Register(token: "123", bundleIdentifier: "com.pusher", metadata: Metadata(sdkVersion: "0.4.0", iosVersion: nil, macosVersion: "10.9"))
    #endif

    #if os(iOS)
    func testRegisterModel() {
        let register = self.register
        XCTAssertNotNil(register)
        XCTAssertEqual(register.token, "123")
        XCTAssertEqual(register.bundleIdentifier, "com.pusher")
        XCTAssertEqual(register.metadata.sdkVersion, "0.4.0")
        XCTAssertEqual(register.metadata.iosVersion, "11.2.0")
        XCTAssertEqual(register.metadata.macosVersion, nil)
    }

    func testRegisterEncoded() {
        let registerEncoded = try! self.register.encode()
        XCTAssertNotNil(registerEncoded)
        let registerJSON = String(data: registerEncoded, encoding: .utf8)!

        let registerDecoded = try! JSONDecoder().decode(Register.self, from: registerJSON.data(using: .utf8)!)

        XCTAssertNotNil(registerDecoded)
        XCTAssertEqual(registerDecoded.token, "123")
        XCTAssertEqual(registerDecoded.bundleIdentifier, "com.pusher")
        XCTAssertEqual(registerDecoded.metadata.sdkVersion, "0.4.0")
        XCTAssertEqual(registerDecoded.metadata.iosVersion, "11.2.0")
        XCTAssertEqual(registerDecoded.metadata.macosVersion, nil)
    }
    #elseif os(OSX)
    func testRegisterModel() {
        let register = self.register
        XCTAssertNotNil(register)
        XCTAssertEqual(register.token, "123")
        XCTAssertEqual(register.bundleIdentifier, "com.pusher")
        XCTAssertEqual(register.metadata.sdkVersion, "0.4.0")
        XCTAssertEqual(register.metadata.iosVersion, nil)
        XCTAssertEqual(register.metadata.macosVersion, "10.9")
    }

    func testRegisterEncoded() {
        let registerEncoded = try! self.register.encode()
        XCTAssertNotNil(registerEncoded)
        let registerJSON = String(data: registerEncoded, encoding: .utf8)!

        let registerDecoded = try! JSONDecoder().decode(Register.self, from: registerJSON.data(using: .utf8)!)

        XCTAssertNotNil(registerDecoded)
        XCTAssertEqual(registerDecoded.token, "123")
        XCTAssertEqual(registerDecoded.bundleIdentifier, "com.pusher")
        XCTAssertEqual(registerDecoded.metadata.sdkVersion, "0.4.0")
        XCTAssertEqual(registerDecoded.metadata.iosVersion, nil)
        XCTAssertEqual(registerDecoded.metadata.macosVersion, "10.9")
    }
    #endif
}
