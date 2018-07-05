import XCTest
import OHHTTPStubs
@testable import PushNotifications

class PushNotificationsNetworkableTests: XCTestCase {

    let interest = "hello"
    let instanceId = "8a070eaa-033f-46d6-bb90-f4c15acc47e1"
    let deviceId = "apns-8792dc3f-45ce-4fd9-ab6d-3bf731f813c6"
    var networkService: PushNotificationsNetworkable!

    func testRegistration() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should successfully register the device")
        let deviceTokenData = "e4cea6a8b2419499c8c716bec80b705d7a5d8864adb2c69400bab9b7abe43ff1".toData()!
        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.register(url: url, deviceToken: deviceTokenData, instanceId: instanceId) { (device) in
            XCTAssertNotNil(device)
            XCTAssert(device?.id == "apns-8792dc3f-45ce-4fd9-ab6d-3bf731f813c6")
            XCTAssertEqual(device?.initialInterestSet?.count, nil)
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

    }

    func testRegistrationWithInitialInterestsSet() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["a", "b", "c", "d"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should successfully register the device")
        let deviceTokenData = "e4cea6a8b2419499c8c716bec80b705d7a5d8864adb2c69400bab9b7abe43ff1".toData()!
        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.register(url: url, deviceToken: deviceTokenData, instanceId: instanceId) { (device) in
            XCTAssertNotNil(device)
            XCTAssert(device?.id == "apns-8792dc3f-45ce-4fd9-ab6d-3bf731f813c6")
            XCTAssertNotNil(device?.initialInterestSet)
            XCTAssertEqual(device?.initialInterestSet?.count, 4)
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

    }

    func testRegistrationWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        let exp = expectation(description: "It should fail to register the device")
        let expRetry = expectation(description: "It should retry to register the device")

        var numberOfAttempts = 0
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "description": "Something went terribly wrong"
            ]

            numberOfAttempts += 1
            if numberOfAttempts == 1 {
                exp.fulfill()
            }
            if numberOfAttempts == 3 {
                expRetry.fulfill()
            }

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 500, headers: nil)
        }

        let deviceTokenData = "e4cea6a8b2419499c8c716bec80b705d7a5d8864adb2c69400bab9b7abe43ff1".toData()!
        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.register(url: url, deviceToken: deviceTokenData, instanceId: instanceId) { (deviceId) in }

        waitForExpectations(timeout: 10)

    }

    func testRegistrationWithIncorrectDeviceToken() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        let exp = expectation(description: "It should fail to register the device")
        let expRetry = expectation(description: "It should retry to register the device")

        var numberOfAttempts = 0
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "description": "[PushNotifications]: Please supply your device APNS token"
            ]

            numberOfAttempts += 1
            if numberOfAttempts == 1 {
                exp.fulfill()
            }
            if numberOfAttempts == 3 {
                expRetry.fulfill()
            }

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 500, headers: nil)
        }

        let deviceTokenData = Data()
        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.register(url: url, deviceToken: deviceTokenData, instanceId: instanceId) { (deviceId) in }

        waitForExpectations(timeout: 10)
    }

    func testSubscribe() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should successfully subscribe to an interest")
        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.subscribe(url: url) { _ in
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

    }

    func testSubscribeWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")!
        let exp = expectation(description: "It should fail to subscribe to an interest")
        let expRetry = expectation(description: "It should retry to subscribe to an interest")

        var numberOfAttempts = 0
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            numberOfAttempts += 1
            if numberOfAttempts == 1 {
                exp.fulfill()
            }
            if numberOfAttempts == 3 {
                expRetry.fulfill()
            }

            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.subscribe(url: url) { _ in }

        waitForExpectations(timeout: 10)

    }

    func testSetSubscriptions() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should successfully subscribe to many interests")
        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.setSubscriptions(url: url, interests: ["a", "b", "c"]) { _ in
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

    }

    func testSetSubscriptionsWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!
        let exp = expectation(description: "It should fail to subscribe to many interests")
        let expRetry = expectation(description: "It should retry to subscribe to many interests")

        var numberOfAttempts = 0
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            numberOfAttempts += 1
            if numberOfAttempts == 1 {
                exp.fulfill()
            }
            if numberOfAttempts == 3 {
                expRetry.fulfill()
            }

            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.setSubscriptions(url: url, interests: ["a", "b", "c"]) { _ in }

        waitForExpectations(timeout: 10)

    }

    func testUnsubscribe() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        let exp = expectation(description: "It should successfully unsubscribe from an interest")
        networkService.unsubscribe(url: url) { _ in
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

    }

    func testUnsubscribeWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")!
        let exp = expectation(description: "It should fail to unsubscribe from an interest")
        let expRetry = expectation(description: "It should retry to unsubscribe from an interest")

        var numberOfAttempts = 0
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            numberOfAttempts += 1
            if numberOfAttempts == 1 {
                exp.fulfill()
            }
            if numberOfAttempts == 3 {
                expRetry.fulfill()
            }

            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.unsubscribe(url: url) { _ in }

        waitForExpectations(timeout: 10)
    }

    func testUnsubscribeAll() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should successfully unsubscribe from all the interests")
        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.setSubscriptions(url: url, interests: []) { _ in
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

    }

    func testUnsubscribeAllWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!
        let exp = expectation(description: "It should fail to unsubscribe from all the interests")
        let expRetry = expectation(description: "It should retry to unsubscribe from all the interests")

        var numberOfAttempts = 0
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            numberOfAttempts += 1
            if numberOfAttempts == 1 {
                exp.fulfill()
            }
            if numberOfAttempts == 3 {
                expRetry.fulfill()
            }

            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.setSubscriptions(url: url, interests: []) { _ in }

        waitForExpectations(timeout: 10)

    }

    #if os(iOS)
    func testTrack() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v1/instances/\(instanceId)/events")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let userInfo = ["data": ["pusher": ["publishId": "1"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active)!
        let exp = expectation(description: "It should successfully track notification")
        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.track(url: url, eventType: eventType) { _ in
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

    }

    func testTrackWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v1/instances/\(instanceId)/events")!
        let exp = expectation(description: "It should fail to track notification")
        let expRetry = expectation(description: "It should retry to track notification")

        var numberOfAttempts = 0
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            numberOfAttempts += 1
            if numberOfAttempts == 1 {
                exp.fulfill()
            }
            if numberOfAttempts == 3 {
                expRetry.fulfill()
            }

            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let userInfo = ["data": ["pusher": ["publishId": "1"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active)!

        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.track(url: url, eventType: eventType) { _ in }

        waitForExpectations(timeout: 10)

    }
    #elseif os(OSX)
    func testTrack() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v1/instances/\(instanceId)/events")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let userInfo = ["data": ["pusher": ["publishId": "1"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo)!
        let exp = expectation(description: "It should successfully track notification")
        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.track(url: url, eventType: eventType) { _ in
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

    }

    func testTrackWithError() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v1/instances/\(instanceId)/events")!
        let exp = expectation(description: "It should fail to track notification")
        let expRetry = expectation(description: "It should retry to track notification")

        var numberOfAttempts = 0
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            numberOfAttempts += 1
            if numberOfAttempts == 1 {
                exp.fulfill()
            }
            if numberOfAttempts == 3 {
                expRetry.fulfill()
            }

            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let userInfo = ["data": ["pusher": ["publishId": "1"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo)!

        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.track(url: url, eventType: eventType) { _ in }

        waitForExpectations(timeout: 10)

    }
    #endif

    func testMetadata() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/metadata")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should successfully sync outdated metadata")
        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.syncMetadata(url: url) { _ in
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)

    }

    func testMetadataWithError() {
        let metadata = Metadata(sdkVersion: "0.0.1", iosVersion: "9.0", macosVersion: nil)
        metadata.save()

        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/metadata")!
        let exp = expectation(description: "It should fail to sync outdated metadata")
        let expRetry = expectation(description: "It should retry to sync outdated metadata")

        var numberOfAttempts = 0
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            numberOfAttempts += 1
            if numberOfAttempts == 1 {
                exp.fulfill()
            }
            if numberOfAttempts == 3 {
                expRetry.fulfill()
            }

            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let networkService = NetworkService(session: URLSession(configuration: .ephemeral))
        networkService.syncMetadata(url: url) { _ in }

        waitForExpectations(timeout: 10)

    }
}
