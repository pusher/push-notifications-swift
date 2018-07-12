import XCTest
@testable import PushNotifications

class InterestsHashTests: XCTestCase {

    override func setUp() {
        UserDefaults(suiteName: "InterestsHash")?.removeObject(forKey: "interestsHash")
    }

    func testInterestsHash() {
        let interestsHash = InterestsHash()
        interestsHash.persist("749e2830366ba863f796cdf5e281662f")

        XCTAssertEqual(interestsHash.serverConfirmedInterestsHash(), "749e2830366ba863f796cdf5e281662f")
    }

    func testInterestsHashWithNil() {
        let interestsHash = InterestsHash()

        XCTAssertEqual(interestsHash.serverConfirmedInterestsHash(), "")
    }
}
