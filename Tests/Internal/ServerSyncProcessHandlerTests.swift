import XCTest
import OHHTTPStubs
@testable import PushNotifications

class ServerSyncProcessHandlerTests: XCTestCase {

    let instanceId = "8a070eaa-033f-46d6-bb90-f4c15acc47e1"
    let deviceId = "apns-8792dc3f-45ce-4fd9-ab6d-3bf731f813c6"
    let deviceToken = "e4cea6a8b2419499c8c716bec80b705d7a5d8864adb2c69400bab9b7abe43ff1"

    override func setUp() {
        super.setUp()

        UserDefaults(suiteName: Constants.UserDefaults.suiteName)?.removeObject(forKey: Constants.UserDefaults.deviceId)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testStartJob() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        let exp = expectation(description: "It should successfully register the device")

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            exp.fulfill()

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(token: deviceToken)
        let serverSyncProcessHandler = ServerSyncProcessHandler(instanceId: instanceId)
        serverSyncProcessHandler.sendMessage(serverSyncJob: startJob)

        waitForExpectations(timeout: 1)
    }

    func testStartJobRetriesDeviceCreation() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        let exp = expectation(description: "It should successfully register the device")

        var numberOfAttempts = 0
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "description": "Something went terribly wrong"
            ]

            numberOfAttempts += 1
            if numberOfAttempts == 2 {
                exp.fulfill()
                return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
            } else {
                return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 500, headers: nil)
            }
        }

        let startJob = ServerSyncJob.StartJob(token: deviceToken)
        let serverSyncProcessHandler = ServerSyncProcessHandler(instanceId: instanceId)
        serverSyncProcessHandler.sendMessage(serverSyncJob: startJob)

        waitForExpectations(timeout: 1)
    }

    func testItShouldSkipJobsBeforeStartJob() {
        let exp = expectation(description: "It should not trigger any server endpoints")
        exp.isInverted = true

        let anyRequestIsFineReally = { (_: URLRequest) in
            return true
        }

        stub(condition: anyRequestIsFineReally) { _ in
            exp.fulfill()
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 500, headers: nil)
        }

        let serverSyncProcessHandler = ServerSyncProcessHandler(instanceId: instanceId)
        let jobs = [ServerSyncJob.RefreshTokenJob(newToken: "1"), ServerSyncJob.SubscribeJob(interest: "abc"), ServerSyncJob.UnsubscribeJob(interest: "12")]

        for job in jobs {
            serverSyncProcessHandler.sendMessage(serverSyncJob: job)
        }

        waitForExpectations(timeout: 1)
    }

    func testItShouldMergeTheRemoteInitialInterestsSetWithLocalInterestSet() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["interest-x", "hello"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let jobs = [
            ServerSyncJob.SubscribeJob(interest: "interest-0"),
            ServerSyncJob.SubscribeJob(interest: "interest-1"),
            ServerSyncJob.SubscribeJob(interest: "interest-2"),
            ServerSyncJob.UnsubscribeJob(interest: "interest-0"),
            ServerSyncJob.UnsubscribeJob(interest: "interest-x"),
            ServerSyncJob.StartJob(token: deviceToken)
        ]

        let serverSyncProcessHandler = ServerSyncProcessHandler(instanceId: instanceId)
        for job in jobs {
            serverSyncProcessHandler.jobQueue.append(job)
            serverSyncProcessHandler.handleMessage(serverSyncJob: job)
        }

        let localInterestsSet = Set(DeviceStateStore.interestsService.getSubscriptions() ?? [])
        let expectedInterestsSet = Set(["interest-1", "interest-2", "hello"])
        XCTAssertEqual(localInterestsSet, expectedInterestsSet)
    }

    func testItShouldMergeTheRemoteInitialInterestsSetWithLocalInterestSetThisTimeUsingSetSubscriptions() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["interest-x", "hello"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let jobs = [
            ServerSyncJob.SubscribeJob(interest: "interest-0"),
            ServerSyncJob.SubscribeJob(interest: "interest-1"),
            ServerSyncJob.UnsubscribeJob(interest: "interest-0"),
            ServerSyncJob.SetSubscriptions(interests: ["cucas", "potatoes", "123"]),
            ServerSyncJob.SubscribeJob(interest: "interest-2"),
            ServerSyncJob.UnsubscribeJob(interest: "interest-x"),
            ServerSyncJob.StartJob(token: deviceToken)
        ]

        let serverSyncProcessHandler = ServerSyncProcessHandler(instanceId: instanceId)
        for job in jobs {
            serverSyncProcessHandler.jobQueue.append(job)
            serverSyncProcessHandler.handleMessage(serverSyncJob: job)
        }

        let localInterestsSet = Set(DeviceStateStore.interestsService.getSubscriptions() ?? [])
        let expectedInterestsSet = Set(["cucas", "potatoes", "123", "interest-2"])
        XCTAssertEqual(localInterestsSet, expectedInterestsSet)
    }

    func testItShouldSetSubscriptionsAfterStartingIfItDiffersFromTheInitialInterestSet() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["interest-x", "hello"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should successfully set subscriptions")
        let setInterestsURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(self.deviceId)/interests")!
        stub(condition: isAbsoluteURLString(setInterestsURL.absoluteString)) { _ in
            exp.fulfill()
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let jobs = [
            ServerSyncJob.SubscribeJob(interest: "interest-0"),
            ServerSyncJob.SubscribeJob(interest: "interest-1"),
            ServerSyncJob.UnsubscribeJob(interest: "interest-0"),
            ServerSyncJob.SetSubscriptions(interests: ["cucas", "potatoes", "123"]),
            ServerSyncJob.SubscribeJob(interest: "interest-2"),
            ServerSyncJob.UnsubscribeJob(interest: "interest-x"),
            ServerSyncJob.StartJob(token: deviceToken)
        ]


        let serverSyncProcessHandler = ServerSyncProcessHandler(instanceId: instanceId)
        for job in jobs {
            serverSyncProcessHandler.jobQueue.append(job)
            serverSyncProcessHandler.handleMessage(serverSyncJob: job)
        }

        let localInterestsSet = Set(DeviceStateStore.interestsService.getSubscriptions() ?? [])
        let expectedInterestsSet = Set(["cucas", "potatoes", "123", "interest-2"])
        XCTAssertEqual(localInterestsSet, expectedInterestsSet)

        waitForExpectations(timeout: 1)
    }

    func testItShouldNotSetSubscriptionsAfterStartingIfItDoesntDifferFromTheInitialInterestSet() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["interest-x", "hello"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should not call set subscriptions")
        exp.isInverted = true
        let setInterestsURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(self.deviceId)/interests")!
        stub(condition: isAbsoluteURLString(setInterestsURL.absoluteString)) { _ in
            exp.fulfill()
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let jobs = [
            ServerSyncJob.SubscribeJob(interest: "hello"),
            ServerSyncJob.StartJob(token: deviceToken)
        ]


        let serverSyncProcessHandler = ServerSyncProcessHandler(instanceId: instanceId)
        for job in jobs {
            serverSyncProcessHandler.jobQueue.append(job)
            serverSyncProcessHandler.handleMessage(serverSyncJob: job)
        }

        let localInterestsSet = Set(DeviceStateStore.interestsService.getSubscriptions() ?? [])
        let expectedInterestsSet = Set(["interest-x", "hello"])
        XCTAssertEqual(localInterestsSet, expectedInterestsSet)

        waitForExpectations(timeout: 1)
    }
}
