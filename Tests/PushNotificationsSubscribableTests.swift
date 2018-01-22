import XCTest
@testable import PushNotifications

class PushNotificationsSubscribableTests: XCTestCase {

    var subscriptionService: PushNotificationsSubscribable!

    override func setUp() {
        self.subscriptionService = MockPushNotificationsSubscribable()
        super.setUp()
    }

    override func tearDown() {
        self.subscriptionService = nil
        super.tearDown()
    }

    func testSubscribe() {
        let exp = expectation(description: "It should successfuly subscribe to an interest")
        self.subscriptionService.subscribe {
            XCTAssert(true)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }

    func testSetSubscriptions() {
        let exp = expectation(description: "It should successfuly subscribe to many interests")
        self.subscriptionService.setSubscriptions(interests: ["a", "b", "c"]) {
            XCTAssert(true)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }

    func testUnsubscribe() {
        let exp = expectation(description: "It should successfuly unsubscribe from an interest")
        self.subscriptionService.unsubscribe {
            XCTAssert(true)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }

    func testUnsubscribeAll() {
        let exp = expectation(description: "It should successfuly unsubscribe from all the interests")
        self.subscriptionService.unsubscribeAll {
            XCTAssert(true)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }
}
