import XCTest
@testable import PushNotifications

class InterestsMD5HashTests: XCTestCase {
    func testCalculatedHashIsCorrect() {
        let interestsMD5Hash1 = ["a", "b", "c", "d", "e"].calculateMD5Hash()
        XCTAssertEqual(interestsMD5Hash1, "fb2ae5db06efd8297195270bdc4fb60b")

        let interestsMD5Hash2 = ["vegan-pizza", "donuts", "zzz", "aaa", "a"].calculateMD5Hash()
        XCTAssertEqual(interestsMD5Hash2, "749e2830366ba863f796cdf5e281662f")
    }
}
