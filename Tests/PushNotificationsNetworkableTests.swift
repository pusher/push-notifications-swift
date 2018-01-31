import XCTest
@testable import PushNotifications

class PushNotificationsSubscribableTests: XCTestCase {

    var subscriptionService: MockPushNotificationsNetworkable!

    override func setUp() {
        self.subscriptionService = MockPushNotificationsNetworkable()
        super.setUp()
    }

    override func tearDown() {
        self.subscriptionService = nil
        super.tearDown()
    }

    func testRegistration() {
        let exp = expectation(description: "It should successfully register the device")
        self.subscriptionService.register(deviceToken: Data(), instanceId: "123") { (deviceId) in
            XCTAssert(deviceId == "apns-876eeb5d-0dc8-4d74-9f59-b65412b2c742")
            XCTAssert(true)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }

    func testSubscribe() {
        let exp = expectation(description: "It should successfully subscribe to an interest")
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
        let exp = expectation(description: "It should successfully subscribe to many interests")
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
        let exp = expectation(description: "It should successfully unsubscribe from an interest")
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
        let exp = expectation(description: "It should successfully unsubscribe from all the interests")
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
