import XCTest
import OHHTTPStubs
@testable import PushNotifications

class PushNotificationsNetworkableTests: XCTestCase {

    let interest = "hello"
    let instanceId = "8a070eaa-033f-46d6-bb90-f4c15acc47e1"
    let deviceId = "apns-8792dc3f-45ce-4fd9-ab6d-3bf731f813c6"

    var networkService: PushNotificationsNetworkable!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testRegistration() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should successfully register the device")
        let deviceTokenData = "e4cea6a8b2419499c8c716bec80b705d7a5d8864adb2c69400bab9b7abe43ff1".toData()!
        networkService.register(deviceToken: deviceTokenData, instanceId: instanceId) { (deviceId, wasSuccessful) in
            XCTAssertNotNil(deviceId)
            XCTAssertTrue(wasSuccessful)
            XCTAssert(deviceId == "apns-8792dc3f-45ce-4fd9-ab6d-3bf731f813c6")
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testRegistrationWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "description": "Something went terribly wrong"
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should fail to register the device")
        let deviceTokenData = "e4cea6a8b2419499c8c716bec80b705d7a5d8864adb2c69400bab9b7abe43ff1".toData()!
        networkService.register(deviceToken: deviceTokenData, instanceId: instanceId) { (deviceId, wasSuccessful) in
            XCTAssertNil(deviceId)
            XCTAssertFalse(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubscribe() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should successfully subscribe to an interest")
        networkService.subscribe { (_, wasSuccessful) in
            XCTAssertTrue(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSubscribeWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should fail to subscribe to an interest")
        networkService.subscribe { (_, wasSuccessful) in
            XCTAssertFalse(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSetSubscriptions() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should successfully subscribe to many interests")
        networkService.setSubscriptions(interests: ["a", "b", "c"]) { (_, wasSuccessful) in
            XCTAssertTrue(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testSetSubscriptionsWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should fail to subscribe to many interests")
        networkService.setSubscriptions(interests: ["a", "b", "c"]) { (_, wasSuccessful) in
            XCTAssertFalse(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testUnsubscribe() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should successfully unsubscribe from an interest")
        networkService.unsubscribe { (_, wasSuccessful) in
            XCTAssertTrue(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testUnsubscribeWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should fail to unsubscribe from an interest")
        networkService.unsubscribe { (_, wasSuccessful) in
            XCTAssertFalse(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testUnsubscribeAll() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should successfully unsubscribe from all the interests")
        let networkService = NetworkService(url: url, session: URLSession.shared)
        networkService.unsubscribeAll { (_, wasSuccessful) in
            XCTAssertTrue(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testUnsubscribeAllWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let exp = expectation(description: "It should fail to unsubscribe from all the interests")
        let networkService = NetworkService(url: url, session: URLSession.shared)
        networkService.unsubscribeAll { (_, wasSuccessful) in
            XCTAssertFalse(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    #if os(iOS)
    func testTrack() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v1/instances/\(instanceId)/events")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let userInfo = ["data": ["pusher": ["publishId": "1"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active)!
        let exp = expectation(description: "It should successfully track notification")
        networkService.track(eventType: eventType) { (_, wasSuccessful) in
            XCTAssertTrue(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testTrackWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v1/instances/\(instanceId)/events")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let userInfo = ["data": ["pusher": ["publishId": "1"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active)!
        let exp = expectation(description: "It should successfully track notification")
        networkService.track(eventType: eventType) { (_, wasSuccessful) in
            XCTAssertFalse(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
    #endif

    func testMetadata() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/metadata")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should successfully sync outdated metadata")
        networkService.syncMetadata { (_, wasSuccessful) in
            XCTAssertTrue(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testMetadataWithError() {
        let metadata = Metadata(sdkVersion: "0.0.1", iosVersion: "9.0", macosVersion: nil)
        metadata.save()
        
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/metadata")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(url: url, session: URLSession.shared)
        let exp = expectation(description: "It should fail to sync outdated metadata")
        networkService.syncMetadata { (_, wasSuccessful) in
            XCTAssertFalse(wasSuccessful)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
