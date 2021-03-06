@testable import PushNotifications
import XCTest

class InterestsTests: XCTestCase {
    private let interests = Interests(interests: ["a", "b", "c"])

    func testContainsInterests() {
        XCTAssertNotNil(self.interests)
    }

    func testInterestsEncoded() throws {
        let interestskEncoded = try self.interests.encode()
        XCTAssertNotNil(interestskEncoded)
        let interestsJSONExpected = "{\"interests\":[\"a\",\"b\",\"c\"]}"
        let interestsJSON = String(data: interestskEncoded, encoding: .utf8)!
        XCTAssertEqual(interestsJSONExpected, interestsJSON)
    }
}
