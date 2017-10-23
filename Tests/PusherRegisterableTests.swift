import XCTest
@testable import Errol

class PusherRegisterableTests: XCTestCase {

    func testRegistration() {
        let pusherRegisterable: PusherRegisterable = MockPusherRegisterable()
        pusherRegisterable.register(deviceToken: Data()) { (deviceId) in
            XCTAssert(deviceId == "ppns-876eeb5d-0dc8-4d74-9f59-b65412b2c742")
        }
    }
}
