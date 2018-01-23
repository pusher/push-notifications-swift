import XCTest
@testable import PushNotifications

class InterestNameValidationTests: XCTestCase {

    // Interest names are limited to 164 characters and can only contain ASCII upper/lower-case letters, numbers or one of _=@,.:

    func testInterestNameIsInvalid() {
        XCTAssertThrowsError(try PushNotifications.shared.subscribe(interest: "#∞¶")) { error in
            guard case InterestValidationError.invalidName(let name) = error else {
                return XCTFail()
            }

            XCTAssertEqual(name, "#∞¶")
        }
    }

    func testInterestNameLengthShouldNotBeZero() {
        let interest = ""
        XCTAssertThrowsError(try PushNotifications.shared.subscribe(interest: interest)) { error in
            guard case InterestValidationError.invalidName(let name) = error else {
                return XCTFail()
            }

            XCTAssertEqual(name, "")
        }
    }

    func testInterestNameLengthIsOver164Characters() {
        let interest = "wWNQYfD7S@LCH@xlMvYs_ct9uXScs50PJWYDsBXtVAkJt1@d_jUwPUITTRH,ibw1FBlVxwNdcYDoz.,BME=1rpBL7i9hha95rA@tsWZ1JENc=W0ok44_l:OkGmz6SUsdTOMq,_NUsQww7D08lWIE5IhRJwYxp92Qvce:1"
        XCTAssertThrowsError(try PushNotifications.shared.subscribe(interest: interest)) { error in
            guard case InterestValidationError.invalidName(let name) = error else {
                return XCTFail()
            }

            XCTAssertTrue(name.count > 164) // Maximum allowed length is 164 characters.
            XCTAssertEqual(name, interest)
        }
    }

    func testSomeInterestNamesAreInvalid() {
        let interests = ["a", "¢123", "b", "#ssss#dds", "£"]
        XCTAssertThrowsError(try PushNotifications.shared.setSubscriptions(interests: interests)) { error in
            guard case InterestValidationError.invalidNames(let names) = error else {
                return XCTFail()
            }

            XCTAssertNotNil(names)
            XCTAssertEqual(names, ["¢123", "#ssss#dds", "£"])
        }
    }
}
