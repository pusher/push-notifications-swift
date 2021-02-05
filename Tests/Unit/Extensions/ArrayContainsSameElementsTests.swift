@testable import PushNotifications
import XCTest

class ArrayContainsSameElementsTests: XCTestCase {
    func testArrayContainsSameElements1() {
        let arrayOne = ["a", "b", "c", "d", "e"]
        let arrayTwo = ["b", "d", "a", "e", "c"]
        XCTAssertTrue(arrayOne.containsSameElements(as: arrayTwo))
    }

    func testArrayContainsSameElements2() {
        let arrayOne = ["a", "b", "c", "d"]
        let arrayTwo = ["b", "d", "a", "e", "c"]
        XCTAssertFalse(arrayOne.containsSameElements(as: arrayTwo))
    }

    func testArrayContainsSameElements3() {
        let arrayOne = ["a", "b", "c", "d", "2"]
        let arrayTwo = ["b", "d", "a", "e", "c"]
        XCTAssertFalse(arrayOne.containsSameElements(as: arrayTwo))
    }

    func testArrayContainsSameElements4() {
        let arrayOne = ["1", "1"]
        let arrayTwo = ["1", "2"]
        XCTAssertFalse(arrayOne.containsSameElements(as: arrayTwo))
    }

    func testArrayContainsSameElements5() {
        let arrayOne = ["-", "adffevs", "2332", ""]
        let arrayTwo = ["adffevs", "", "", "2332"]
        XCTAssertFalse(arrayOne.containsSameElements(as: arrayTwo))
    }

    func testArrayContainsSameElements6() {
        let arrayOne = ["com.pusher.sdk:123", "com.pusher.sdk:12321", "123"]
        let arrayTwo = ["123", "com.pusher.sdk:123", "com.pusher.sdk:12321"]
        XCTAssertTrue(arrayOne.containsSameElements(as: arrayTwo))
    }
}
