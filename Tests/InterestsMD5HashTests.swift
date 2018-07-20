import XCTest
@testable import PushNotifications

class InterestsMD5HashTests: XCTestCase {
    func testCalculatedHashIsCorrect() {
        let interestsMD5Hash1 = ["a", "b", "c", "d", "e"].calculateMD5Hash()
        XCTAssertEqual(interestsMD5Hash1, "FB2AE5DB06EFD8297195270BDC4FB60B")

        let interestsMD5Hash2 = ["vegan-pizza", "donuts", "zzz", "aaa", "a"].calculateMD5Hash()
        XCTAssertEqual(interestsMD5Hash2, "749E2830366BA863F796CDF5E281662F")
    }
}
