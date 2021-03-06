import Nimble
@testable import PushNotifications
import XCTest

class ClearAllStateTest: XCTestCase {
    // Real production instance.
    private let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    private let validToken = "notadevicetoken-apns-ClearAllStateTest".data(using: .utf8)!

    override func setUp() {
        super.setUp()
        TestHelper.clearEverything(instanceId: instanceId)
    }

    override func tearDown() {
        TestHelper.clearEverything(instanceId: instanceId)
        super.tearDown()
    }

    func testItShouldClearAllState() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        let deviceStateStore = InstanceDeviceStateStore(self.instanceId)
        expect(deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: .seconds(10))
        let deviceId = deviceStateStore.getDeviceId()

        XCTAssertNoThrow(try pushNotifications.addDeviceInterest(interest: "a"))
        XCTAssertEqual(pushNotifications.getDeviceInterests(), ["a"])
        let exp = expectation(description: "Clear all state completion handler must be called")
        pushNotifications.clearAllState {
            exp.fulfill()
        }

        expect(TestAPIClientHelper().getDevice(instanceId: self.instanceId, deviceId: deviceId!))
            .toEventually(beNil(), timeout: .seconds(10))

        XCTAssertEqual(pushNotifications.getDeviceInterests(), [])
        expect(InstanceDeviceStateStore(self.instanceId).getDeviceId()).toEventuallyNot(equal(deviceId!), timeout: .seconds(10))

        waitForExpectations(timeout: 1)
    }
}
