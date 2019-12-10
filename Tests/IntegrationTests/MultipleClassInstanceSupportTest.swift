import XCTest
import Nimble
@testable import PushNotifications

class MultipleClassInstanceSupportTest: XCTestCase {
    let validToken = "notadevicetoken-apns-MultipleClassInstanceSupportTest".data(using: .utf8)!
    let deviceStateStore = InstanceDeviceStateStore(TestHelper.instanceId)
    let validCucasJWTToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjQ3MDc5OTIzMDIsImlzcyI6Imh0dHBzOi8vMWI4ODA1OTAtNjMwMS00YmI1LWIzNGYtNDVkYjFjNWY1NjQ0LnB1c2hub3RpZmljYXRpb25zLnB1c2hlci5jb20iLCJzdWIiOiJjdWNhcyJ9.CTtrDXh7vae3rSSKBKf5X0y4RQpFg7YvIlirmBQqJn4"
    
    override func setUp() {
        super.setUp()
        TestHelper.clearEverything(instanceId: TestHelper.instanceId)
    }
    
    override func tearDown() {
        TestHelper.clearEverything(instanceId: TestHelper.instanceId)
        super.tearDown()
    }
    
    func testStopCallbacksShouldCallOnTheRightCallback() {
        let pushNotifications1 = PushNotifications(instanceId: TestHelper.instanceId)
        let pushNotifications2 = PushNotifications(instanceId: TestHelper.instanceId)
        
        pushNotifications1.start()
        pushNotifications1.registerDeviceToken(validToken)
        
        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = self.deviceStateStore.getDeviceId()!
        
        let exp = expectation(description: "Stop completion handler must be called")
        pushNotifications2.stop {
            exp.fulfill()
        }
        
        expect(TestAPIClientHelper().getDevice(instanceId: TestHelper.instanceId, deviceId: deviceId))
            .toEventually(beNil(), timeout: 10)
        
        waitForExpectations(timeout: 1)
    }
    
    func testSetUserIdsCalledOnCorrectCallback () {
        let pushNotifications1 = PushNotifications(instanceId: TestHelper.instanceId)
        let pushNotifications2 = PushNotifications(instanceId: TestHelper.instanceId)
        
        pushNotifications1.start()
        pushNotifications2.start()
        pushNotifications1.registerDeviceToken(validToken)
        
        let tokenProvider = StubTokenProvider(jwt: validCucasJWTToken, error: nil)
        let exp = expectation(description: "It should not return an error")
        pushNotifications2.setUserId("cucas", tokenProvider: tokenProvider) { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10)
    }
    
    func testInterestsChangedDelegateCalledOnCorrectCallback() {
        let pushNotifications1 = PushNotifications(instanceId: TestHelper.instanceId)
        let pushNotifications2 = PushNotifications(instanceId: TestHelper.instanceId)
        
        class StubInterestsChanged: InterestsChangedDelegate {
            let completion: ([String]) -> ()
            init(completion: @escaping ([String]) -> ()) {
                self.completion = completion
            }

            func interestsSetOnDeviceDidChange(interests: [String]) {
                completion(interests)
            }
        }
        let exp = expectation(description: "Interests changed called with ['panda']")
        let stubInterestsChanged = StubInterestsChanged(completion: { interests in
            XCTAssertTrue(interests.containsSameElements(as: ["panda"]))
            exp.fulfill()
        })
        pushNotifications1.delegate = stubInterestsChanged
        
        XCTAssertNoThrow(try! pushNotifications2.addDeviceInterest(interest: "panda"))

        waitForExpectations(timeout: 1)
    }
    
    func testClearAllOnSameInstanceWorks() {
        let pushNotifications1 = PushNotifications(instanceId: TestHelper.instanceId)
        let pushNotifications2 = PushNotifications(instanceId: TestHelper.instanceId)
        
        pushNotifications1.start()
        pushNotifications1.registerDeviceToken(validToken)

        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = self.deviceStateStore.getDeviceId()!
        
        pushNotifications2.clearAllState { }
        
        expect(self.deviceStateStore.getDeviceId()).toEventuallyNot(be(deviceId), timeout: 10)
    }
    
    class StubTokenProvider: TokenProvider {
        private let jwt: String
        private let error: Error?
        
        init(jwt: String, error: Error?) {
            self.jwt = jwt
            self.error = error
        }
        
        func fetchToken(userId: String, completionHandler completion: @escaping (String, Error?) -> Void) throws {
            completion(jwt, error)
        }
    }
    
}
