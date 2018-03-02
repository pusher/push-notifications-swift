import XCTest
@testable import PushNotifications

class PushNotificationsNetworkableTests: XCTestCase {

    let interest = "hello"
    let instanceId = "f918950d-476d-4649-b38e-6cc8d30e0827"
    let deviceId = "apns-18008123-7988-4497-b529-dfe27b116694"

    var networkService: PushNotificationsNetworkable!

    func testRegistration() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should successfully register the device")
        let deviceTokenData = "d338c50c5efdc1b0898950945cd767e704d5b24ae2a48cb76da5b4c9534f940e".toData()!
        networkService.register(deviceToken: deviceTokenData, instanceId: instanceId) { (deviceId) in
            XCTAssert(deviceId == "apns-18008123-7988-4497-b529-dfe27b116694")
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
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")!
        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should successfully subscribe to an interest")
        networkService.subscribe {
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
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!
        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should successfully subscribe to many interests")
        networkService.setSubscriptions(interests: ["a", "b", "c"]) {
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
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")!
        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should successfully unsubscribe from an interest")
        networkService.unsubscribe {
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
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!
        let networkService = NetworkService(url: url, session: URLSession.shared)
        networkService.unsubscribeAll {
            XCTAssert(true)
        }
    }

    func testTrack() {
        // Add integration test.
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v1/instances/\(instanceId)/events")!
        let networkService = NetworkService(url: url, session: URLSession.shared)
        let userInfo = ["aps": ["alert": "hello"]]
        networkService.track(userInfo: userInfo, eventType: ReportEventType.Delivery.rawValue, deviceId: "abc")
        XCTAssert(true)
    }

    func testMetadata() {
        // Add integration test.
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/metadata")!
        let networkService = NetworkService(url: url, session: URLSession.shared)
        networkService.syncMetadata()
        XCTAssert(true)
    }
}
