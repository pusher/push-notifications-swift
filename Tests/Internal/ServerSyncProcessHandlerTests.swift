import XCTest
import OHHTTPStubs
@testable import PushNotifications

class ServerSyncProcessHandlerTests: XCTestCase {

    let instanceId = "8a070eaa-033f-46d6-bb90-f4c15acc47e1"
    let deviceId = "apns-8792dc3f-45ce-4fd9-ab6d-3bf731f813c6"
    let deviceToken = "e4cea6a8b2419499c8c716bec80b705d7a5d8864adb2c69400bab9b7abe43ff1"
    let noTokenProvider: () -> TokenProvider? = {
        return nil
    }

    let ignoreServerSyncEvent: (ServerSyncEvent) -> Void = { _ in
        return
    }

    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }

        Instance.persist(instanceId)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    func testStartJob() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        let exp = expectation(description: "It should successfully register the device")

        stub(condition: isMethodPOST() && isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            exp.fulfill()

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        waitForExpectations(timeout: 1)
    }

    func testStartJobRetriesDeviceCreation() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        let exp = expectation(description: "It should successfully register the device")

        var numberOfAttempts = 0
        stub(condition: isMethodPOST() && isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "description": "Something went terribly wrong"
            ]

            numberOfAttempts += 1
            if numberOfAttempts == 2 {
                exp.fulfill()
                let jsonObject: [String: Any] = [
                    "id": self.deviceId
                ]

                return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
            } else {
                return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 500, headers: nil)
            }
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

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

        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        let jobs = [ServerSyncJob.RefreshTokenJob(newToken: "1"), ServerSyncJob.SubscribeJob(interest: "abc", localInterestsChanged: true), ServerSyncJob.UnsubscribeJob(interest: "12", localInterestsChanged: true)]

        for job in jobs {
            serverSyncProcessHandler.jobQueue.append(job)
            serverSyncProcessHandler.handleMessage(serverSyncJob: job)
        }

        waitForExpectations(timeout: 1)
    }

    func testItShouldMergeTheRemoteInitialInterestsSetWithLocalInterestSet() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isMethodPOST() && isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["interest-x", "hello"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let jobs = [
            ServerSyncJob.SubscribeJob(interest: "interest-0", localInterestsChanged: true),
            ServerSyncJob.SubscribeJob(interest: "interest-1", localInterestsChanged: true),
            ServerSyncJob.SubscribeJob(interest: "interest-2", localInterestsChanged: true),
            ServerSyncJob.UnsubscribeJob(interest: "interest-0", localInterestsChanged: true),
            ServerSyncJob.UnsubscribeJob(interest: "interest-x", localInterestsChanged: true),
            ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        ]

        let expectedInterestsSet = Set(["interest-1", "interest-2", "hello"])

        let exp = expectation(description: "Interests changed callback has been called")
        let handleServerSyncEvent: (ServerSyncEvent) -> Void = { event in
            switch event {
            case .InterestsChangedEvent(let interests):
                XCTAssertTrue(interests.containsSameElements(as: Array(expectedInterestsSet)))
                exp.fulfill()
            default:
                XCTFail()
            }
            return
        }

        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: handleServerSyncEvent)
        for job in jobs {
            serverSyncProcessHandler.jobQueue.append(job)
            serverSyncProcessHandler.handleMessage(serverSyncJob: job)
        }

        let localInterestsSet = Set(DeviceStateStore.interestsService.getSubscriptions() ?? [])
        XCTAssertEqual(localInterestsSet, expectedInterestsSet)

        waitForExpectations(timeout: 1)
    }

    func testItShouldMergeTheRemoteInitialInterestsSetWithLocalInterestSetThisTimeUsingSetSubscriptions() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isMethodPOST() && isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["interest-x", "hello"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let jobs = [
            ServerSyncJob.SubscribeJob(interest: "interest-0", localInterestsChanged: true),
            ServerSyncJob.SubscribeJob(interest: "interest-1", localInterestsChanged: true),
            ServerSyncJob.UnsubscribeJob(interest: "interest-0", localInterestsChanged: true),
            ServerSyncJob.SetSubscriptions(interests: ["cucas", "potatoes", "123"], localInterestsChanged: true),
            ServerSyncJob.SubscribeJob(interest: "interest-2", localInterestsChanged: true),
            ServerSyncJob.UnsubscribeJob(interest: "interest-x", localInterestsChanged: true),
            ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        ]

        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
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

        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["interest-x", "hello"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should successfully set subscriptions")
        let setInterestsURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(self.deviceId)/interests")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(setInterestsURL.absoluteString)) { _ in
            exp.fulfill()
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let jobs = [
            ServerSyncJob.SubscribeJob(interest: "interest-0", localInterestsChanged: true),
            ServerSyncJob.SubscribeJob(interest: "interest-1", localInterestsChanged: true),
            ServerSyncJob.UnsubscribeJob(interest: "interest-0", localInterestsChanged: true),
            ServerSyncJob.SetSubscriptions(interests: ["cucas", "potatoes", "123"], localInterestsChanged: true),
            ServerSyncJob.SubscribeJob(interest: "interest-2", localInterestsChanged: true),
            ServerSyncJob.UnsubscribeJob(interest: "interest-x", localInterestsChanged: true),
            ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        ]


        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
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

        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["interest-x", "hello"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should not call set subscriptions")
        exp.isInverted = true
        let setInterestsURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(self.deviceId)/interests")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(setInterestsURL.absoluteString)) { _ in
            exp.fulfill()
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let jobs = [
            ServerSyncJob.SubscribeJob(interest: "hello", localInterestsChanged: true),
            ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        ]


        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        for job in jobs {
            serverSyncProcessHandler.jobQueue.append(job)
            serverSyncProcessHandler.handleMessage(serverSyncJob: job)
        }

        let localInterestsSet = Set(DeviceStateStore.interestsService.getSubscriptions() ?? [])
        let expectedInterestsSet = Set(["interest-x", "hello"])
        XCTAssertEqual(localInterestsSet, expectedInterestsSet)

        waitForExpectations(timeout: 1)
    }

    func testStopJobBeforeStartSHouldNotThrowAnError() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["interest-x", "hello"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let jobs = [
            ServerSyncJob.StopJob,
            ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        ]


        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        for job in jobs {
            serverSyncProcessHandler.jobQueue.append(job)
            serverSyncProcessHandler.handleMessage(serverSyncJob: job)
        }
    }

    func testStopJobWillDeleteDeviceRemotelyAndLocally() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId,
                "initialInterestSet": ["interest-x", "hello"]
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let deleteURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)")!

        stub(condition: isAbsoluteURLString(deleteURL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        XCTAssertNotNil(Device.getDeviceId())
        XCTAssertNotNil(Device.getAPNsToken())

        let stopJob = ServerSyncJob.StopJob
        serverSyncProcessHandler.jobQueue.append(stopJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: stopJob)

        XCTAssertNil(Device.getDeviceId())
        XCTAssertNil(Device.getAPNsToken())
    }

    func testThatSubscribingUnsubscribingAndSetSubscriptionsWillTriggerTheAPI() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        var expRegisterCalled = false
        var expSubscribeCalled = false
        var expUnsubscribeCalled = false
        var expSetSubscriptionsCalled = false

        stub(condition: isMethodPOST() && isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            expRegisterCalled = true

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let addInterestURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(self.deviceId)/interests/hello")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(addInterestURL.absoluteString)) { _ in
            expSubscribeCalled = true
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let removeInterestURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(self.deviceId)/interests/hello")!
        stub(condition: isMethodDELETE() && isAbsoluteURLString(removeInterestURL.absoluteString)) { _ in
            expUnsubscribeCalled = true
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let setSubscriptionsURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(self.deviceId)/interests")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(setSubscriptionsURL.absoluteString)) { _ in
            expSetSubscriptionsCalled = true
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let jobs = [
            ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken),
            ServerSyncJob.SubscribeJob(interest: "hello", localInterestsChanged: true),
            ServerSyncJob.UnsubscribeJob(interest: "hello", localInterestsChanged: true),
            ServerSyncJob.SetSubscriptions(interests: ["1", "2"], localInterestsChanged: true)
        ]

        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        for job in jobs {
            serverSyncProcessHandler.jobQueue.append(job)
            serverSyncProcessHandler.handleMessage(serverSyncJob: job)
        }

        XCTAssertTrue(expRegisterCalled)
        XCTAssertTrue(expSubscribeCalled)
        XCTAssertTrue(expUnsubscribeCalled)
        XCTAssertTrue(expSetSubscriptionsCalled)
    }

    func testDeviceRecreation() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        let newDeviceId = "new-device-id"
        var isFirstTimeRegistering = true
        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            var jsonObject: [String: Any] = [:]

            if isFirstTimeRegistering {
                jsonObject["id"] = self.deviceId
            } else {
                jsonObject["id"] = newDeviceId
            }

            isFirstTimeRegistering = false

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let subscribeURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/hello")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(subscribeURL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 404, headers: nil)
        }

        let subscribe2URL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(newDeviceId)/interests/hello")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(subscribe2URL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        XCTAssertNotNil(Device.getDeviceId())
        XCTAssertNotNil(Device.getAPNsToken())

        let subscribeJob = ServerSyncJob.SubscribeJob(interest: "hello", localInterestsChanged: true)
        serverSyncProcessHandler.jobQueue.append(subscribeJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: subscribeJob)

        XCTAssertEqual(Device.getDeviceId(), newDeviceId)
    }

    func testDeviceRecreationShouldClearPreviousUserIdIfTokenProviderIsMissing() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!

        let newDeviceId = "new-device-id"
        var isFirstTimeRegistering = true
        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            var jsonObject: [String: Any] = [:]

            if isFirstTimeRegistering {
                jsonObject["id"] = self.deviceId
            } else {
                jsonObject["id"] = newDeviceId
            }

            isFirstTimeRegistering = false

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let subscribeURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests/hello")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(subscribeURL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 404, headers: nil)
        }

        let subscribe2URL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(newDeviceId)/interests/hello")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(subscribe2URL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        // Pretending we already stored the user id.
        DeviceStateStore.usersService.setUserId(userId: "cucas")

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        XCTAssertNotNil(Device.getDeviceId())
        XCTAssertNotNil(Device.getAPNsToken())

        let subscribeJob = ServerSyncJob.SubscribeJob(interest: "hello", localInterestsChanged: true)
        serverSyncProcessHandler.jobQueue.append(subscribeJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: subscribeJob)

        XCTAssertEqual(Device.getDeviceId(), newDeviceId)
        XCTAssertNil(DeviceStateStore.usersService.getUserId())
    }

    func testMetadataSynchonizationWhenAppStarts() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let deleteURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)")!
        stub(condition: isAbsoluteURLString(deleteURL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        var numMetadataCalled = 0
        let metadataURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/metadata")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(metadataURL.absoluteString)) { _ in
            numMetadataCalled += 1
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let metadata = Metadata(sdkVersion: "123", iosVersion: "11", macosVersion: nil)
        let applicationStartJob = ServerSyncJob.ApplicationStartJob(metadata: metadata)
        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.jobQueue.append(applicationStartJob)
        serverSyncProcessHandler.jobQueue.append(applicationStartJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)
        XCTAssertEqual(numMetadataCalled, 0)
        serverSyncProcessHandler.handleMessage(serverSyncJob: applicationStartJob)
        XCTAssertEqual(numMetadataCalled, 1)
        serverSyncProcessHandler.handleMessage(serverSyncJob: applicationStartJob)
        XCTAssertEqual(numMetadataCalled, 1) // It didn't change.

        // ... and stopping and starting the SDK will lead to the same result
        numMetadataCalled = 0
        let stopJob = ServerSyncJob.StopJob
        serverSyncProcessHandler.jobQueue.append(stopJob)
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.jobQueue.append(applicationStartJob)
        serverSyncProcessHandler.jobQueue.append(applicationStartJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: stopJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)
        XCTAssertEqual(numMetadataCalled, 0)
        serverSyncProcessHandler.handleMessage(serverSyncJob: applicationStartJob)
        XCTAssertEqual(numMetadataCalled, 1)
        serverSyncProcessHandler.handleMessage(serverSyncJob: applicationStartJob)
        XCTAssertEqual(numMetadataCalled, 1) // It didn't change.
    }

    func testInterestsSynchonizationWhenAppStarts() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let deleteURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)")!
        stub(condition: isAbsoluteURLString(deleteURL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        var numInterestsCalled = 0
        let setInterestsURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(setInterestsURL.absoluteString)) { _ in
            numInterestsCalled += 1
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let metadata = Metadata(sdkVersion: "123", iosVersion: "11", macosVersion: nil)
        let applicationStartJob = ServerSyncJob.ApplicationStartJob(metadata: metadata)
        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.jobQueue.append(applicationStartJob)
        serverSyncProcessHandler.jobQueue.append(applicationStartJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)
        XCTAssertEqual(numInterestsCalled, 0)
        serverSyncProcessHandler.handleMessage(serverSyncJob: applicationStartJob)
        XCTAssertEqual(numInterestsCalled, 1)
        serverSyncProcessHandler.handleMessage(serverSyncJob: applicationStartJob)
        XCTAssertEqual(numInterestsCalled, 1) // It didn't change.

        // ... and stopping and starting the SDK will lead to the same result
        numInterestsCalled = 0
        let stopJob = ServerSyncJob.StopJob
        serverSyncProcessHandler.jobQueue.append(stopJob)
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.jobQueue.append(applicationStartJob)
        serverSyncProcessHandler.jobQueue.append(applicationStartJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: stopJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)
        XCTAssertEqual(numInterestsCalled, 0)
        serverSyncProcessHandler.handleMessage(serverSyncJob: applicationStartJob)
        XCTAssertEqual(numInterestsCalled, 1)
        serverSyncProcessHandler.handleMessage(serverSyncJob: applicationStartJob)
        XCTAssertEqual(numInterestsCalled, 1) // It didn't change.
    }

    func testSetUserIdAfterStartShouldSetTheUserIdInTheServerAndLocalStorage() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let setUserIdJob = ServerSyncJob.SetUserIdJob(userId: "cucas")
        let tokenProvider = StubTokenProvider(jwt: "dummy-jwt", error: nil)
        let serverSyncProcessHandler = ServerSyncProcessHandler(
            getTokenProvider: { return tokenProvider },
            handleServerSyncEvent: { _ in return }
        )
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        let exp = expectation(description: "Set user id will be called in the server")
        let setUserIdURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/user")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(setUserIdURL.absoluteString)) { _ in
            exp.fulfill()
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        serverSyncProcessHandler.jobQueue.append(setUserIdJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: setUserIdJob)

        waitForExpectations(timeout: 1)

        XCTAssertNotNil(DeviceStateStore.usersService.getUserId())
    }

    func testSetUserIdSuccessCallbackIsCalled() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let setUserIdJob = ServerSyncJob.SetUserIdJob(userId: "cucas")
        let tokenProvider = StubTokenProvider(jwt: "dummy-jwt", error: nil)

        let exp = expectation(description: "Callback should be called")

        let serverSyncProcessHandler = ServerSyncProcessHandler(
            getTokenProvider: { return tokenProvider },
            handleServerSyncEvent: { event in
                switch event {
                case .UserIdSetEvent("cucas", nil):
                    exp.fulfill()
                default:
                    XCTFail()
                }
            }
        )
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        let setUserIdURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/user")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(setUserIdURL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        serverSyncProcessHandler.jobQueue.append(setUserIdJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: setUserIdJob)

        waitForExpectations(timeout: 1)
    }

    func testSetUserIdTokenProviderNilError() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let setUserIdJob = ServerSyncJob.SetUserIdJob(userId: "cucas")

        let exp = expectation(description: "Callback should be called")

        let serverSyncProcessHandler = ServerSyncProcessHandler(
            getTokenProvider: { return nil },
            handleServerSyncEvent: { event in
                switch event {
                case .UserIdSetEvent("cucas", let error):
                    XCTAssertNotNil(error)
                    exp.fulfill()
                default:
                    XCTFail()
                }
        }
        )
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        let setUserIdURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/user")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(setUserIdURL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        serverSyncProcessHandler.jobQueue.append(setUserIdJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: setUserIdJob)

        waitForExpectations(timeout: 1)
    }

    func testSetUserIdTokenProviderReturnsError() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let setUserIdJob = ServerSyncJob.SetUserIdJob(userId: "cucas")
        let tokenProvider = StubTokenProvider(jwt: "dummy-jwt", error: TokenProviderError.error("Error"))

        let exp = expectation(description: "Callback should be called")

        let serverSyncProcessHandler = ServerSyncProcessHandler(
            getTokenProvider: { return tokenProvider },
            handleServerSyncEvent: { event in
                switch event {
                case .UserIdSetEvent("cucas", let error):
                    XCTAssertNotNil(error)
                    exp.fulfill()
                default:
                    XCTFail()
                }
        }
        )
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        let setUserIdURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/user")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(setUserIdURL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        serverSyncProcessHandler.jobQueue.append(setUserIdJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: setUserIdJob)

        waitForExpectations(timeout: 1)
    }

    func testSetUserIdBeamsServerRejectsTheRequest() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let setUserIdJob = ServerSyncJob.SetUserIdJob(userId: "cucas")
        let tokenProvider = StubTokenProvider(jwt: "dummy-jwt", error: nil)

        let exp = expectation(description: "Callback should be called")

        let serverSyncProcessHandler = ServerSyncProcessHandler(
            getTokenProvider: { return tokenProvider },
            handleServerSyncEvent: { event in
                switch event {
                case .UserIdSetEvent("cucas", let error):
                    XCTAssertNotNil(error)
                    exp.fulfill()
                default:
                    XCTFail()
                }
        }
        )
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        let setUserIdURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/user")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(setUserIdURL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 400, headers: nil)
        }

        serverSyncProcessHandler.jobQueue.append(setUserIdJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: setUserIdJob)

        waitForExpectations(timeout: 1)
    }

    func testSetUserIdTokenProviderThrowsException() {
        let registerURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(registerURL.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)
        let setUserIdJob = ServerSyncJob.SetUserIdJob(userId: "cucas")
        let tokenProvider = StubTokenProvider(jwt: "dummy-jwt", error: nil, exception: PushNotificationsError.error("💣"))

        let exp = expectation(description: "Callback should be called")

        let serverSyncProcessHandler = ServerSyncProcessHandler(
            getTokenProvider: { return tokenProvider },
            handleServerSyncEvent: { event in
                switch event {
                case .UserIdSetEvent("cucas", let error):
                    XCTAssertNotNil(error)
                    exp.fulfill()
                default:
                    XCTFail()
                }
        }
        )
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        let setUserIdURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/user")!
        stub(condition: isMethodPUT() && isAbsoluteURLString(setUserIdURL.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        serverSyncProcessHandler.jobQueue.append(setUserIdJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: setUserIdJob)

        waitForExpectations(timeout: 1)
    }

    #if os(iOS)
    func testTrackWillSendEventTypeToTheServer() {
        let url = URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        var expRegisterCalled = false
        var trackCalled = false

        stub(condition: isMethodPOST() && isAbsoluteURLString(url.absoluteString)) { _ in
            let jsonObject: [String: Any] = [
                "id": self.deviceId
            ]

            expRegisterCalled = true

            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let trackURL = URL(string: "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v2/instances/\(instanceId)/events")!
        stub(condition: isMethodPOST() && isAbsoluteURLString(trackURL.absoluteString)) { _ in
            trackCalled = true
            return OHHTTPStubsResponse(jsonObject: [], statusCode: 200, headers: nil)
        }

        let startJob = ServerSyncJob.StartJob(instanceId: instanceId, token: deviceToken)

        let serverSyncProcessHandler = ServerSyncProcessHandler(getTokenProvider: noTokenProvider, handleServerSyncEvent: ignoreServerSyncEvent)
        serverSyncProcessHandler.jobQueue.append(startJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: startJob)

        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active) as! DeliveryEventType

        let trackEventJob = ServerSyncJob.ReportEventJob(eventType: eventType)

        serverSyncProcessHandler.jobQueue.append(trackEventJob)
        serverSyncProcessHandler.handleMessage(serverSyncJob: trackEventJob)

        XCTAssertTrue(expRegisterCalled)
        XCTAssertTrue(trackCalled)
    }
    #endif

    class StubTokenProvider: TokenProvider {
        private let jwt: String
        private let error: Error?
        private let exception: Error?

        init(jwt: String, error: Error?, exception: Error? = nil) {
            self.jwt = jwt
            self.error = error
            self.exception = exception
        }

        func fetchToken(userId: String, completionHandler completion: @escaping (String, Error?) -> Void) throws {
            if let exception = self.exception {
                throw exception
            }

            completion(jwt, error)
        }
    }
}
