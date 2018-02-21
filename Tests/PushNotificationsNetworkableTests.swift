import XCTest
@testable import PushNotifications

class PushNotificationsSubscribableTests: XCTestCase {

    var networkService: MockPushNotificationsNetworkable!

    override func setUp() {
        self.networkService = MockPushNotificationsNetworkable()
        super.setUp()
    }

    override func tearDown() {
        self.networkService = nil
        super.tearDown()
    }

    func testRegistration() {
        let exp = expectation(description: "It should successfully register the device")
        self.networkService.register(deviceToken: Data(), instanceId: "123") { (deviceId) in
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
        self.networkService.subscribe {
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
        self.networkService.setSubscriptions(interests: ["a", "b", "c"]) {
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
        self.networkService.unsubscribe {
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
        self.networkService.unsubscribeAll {
            XCTAssert(true)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
    }

    func testTrack() {
        let userInfo = ["aps": ["alert": "hello"]]
        self.networkService.track(userInfo: userInfo, eventType: ReportEventType.Delivery.rawValue, deviceId: "abc")
        XCTAssert(true)
    }

    func testMetadata() {
        self.networkService.sendMetadata()
        XCTAssert(true)
    }
}
