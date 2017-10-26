import XCTest
@testable import Errol

class ErrolRegisterableTests: XCTestCase {

    func testRegistration() {
        let errolRegisterable: ErrolRegisterable = MockErrolRegisterable()
        errolRegisterable.register(deviceToken: Data()) { (deviceId) in
            XCTAssert(deviceId == "apns-876eeb5d-0dc8-4d74-9f59-b65412b2c742")
        }
    }
}
