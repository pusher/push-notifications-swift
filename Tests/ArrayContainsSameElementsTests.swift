import XCTest
@testable import PushNotifications

class ArrayContainsSameElementsTests: XCTestCase {
    func testArrayContainsSameElements1() {
        let a = ["a", "b", "c", "d", "e"]
        let b = ["b", "d", "a", "e", "c"]
        XCTAssertTrue(a.containsSameElements(as: b))
    }

    func testArrayContainsSameElements2() {
        let a = ["a", "b", "c", "d"]
        let b = ["b", "d", "a", "e", "c"]
        XCTAssertFalse(a.containsSameElements(as: b))
    }

    func testArrayContainsSameElements3() {
        let a = ["a", "b", "c", "d", "2"]
        let b = ["b", "d", "a", "e", "c"]
        XCTAssertFalse(a.containsSameElements(as: b))
    }

    func testArrayContainsSameElements4() {
        let a = ["1", "1"]
        let b = ["1", "2"]
        XCTAssertFalse(a.containsSameElements(as: b))
    }

    func testArrayContainsSameElements5() {
        let a = ["-", "adffevs", "2332", ""]
        let b = ["adffevs", "", "", "2332"]
        XCTAssertFalse(a.containsSameElements(as: b))
    }

    func testArrayContainsSameElements6() {
        let a = ["com.pusher.sdk:123", "com.pusher.sdk:12321", "123"]
        let b = ["123", "com.pusher.sdk:123", "com.pusher.sdk:12321"]
        XCTAssertTrue(a.containsSameElements(as: b))
    }
}
