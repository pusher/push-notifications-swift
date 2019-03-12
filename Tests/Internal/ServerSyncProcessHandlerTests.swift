import XCTest
import OHHTTPStubs
@testable import PushNotifications

class ServerSyncProcessHandlerTests: XCTestCase {

    let instanceId = "8a070eaa-033f-46d6-bb90-f4c15acc47e1"
    let deviceId = "apns-8792dc3f-45ce-4fd9-ab6d-3bf731f813c6"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

        let deviceToken = "e4cea6a8b2419499c8c716bec80b705d7a5d8864adb2c69400bab9b7abe43ff1"

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

        let deviceToken = "e4cea6a8b2419499c8c716bec80b705d7a5d8864adb2c69400bab9b7abe43ff1"

        let startJob = ServerSyncJob.StartJob(token: deviceToken)
        let serverSyncProcessHandler = ServerSyncProcessHandler(instanceId: instanceId)
        serverSyncProcessHandler.sendMessage(serverSyncJob: startJob)

        waitForExpectations(timeout: 1)
    }
}
