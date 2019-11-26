import XCTest
import Nimble
@testable import PushNotifications

class MultipleInstanceSupportTest: XCTestCase {
    
    let validCucasToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjQ3MDc5OTIzMDIsImlzcyI6Imh0dHBzOi8vMWI4ODA1OTAtNjMwMS00YmI1LWIzNGYtNDVkYjFjNWY1NjQ0LnB1c2hub3RpZmljYXRpb25zLnB1c2hlci5jb20iLCJzdWIiOiJjdWNhcyJ9.CTtrDXh7vae3rSSKBKf5X0y4RQpFg7YvIlirmBQqJn4"
    let validJessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjQ3MDc5OTIzMDIsImlzcyI6Imh0dHBzOi8vOGJhNzZkYWMtYjJkZS00NzJmLWJjZjItNzRjY2E0MzhlYTEzLnB1c2hub3RpZmljYXRpb25zLnB1c2hlci5jb20iLCJzdWIiOiJqZXNzIn0.1x2qaxoOtMuz6CYxLOdySUjm7ivSH6AKkRqNmCqWe9o"
    let validAPNsToken = "notadevicetoken-apns-SetUserIdTest".data(using: .utf8)!

    override func setUp() {
        super.setUp()
        TestHelper.clearEverything(instanceId: TestHelper.instanceId)
        TestHelper.clearEverything(instanceId: TestHelper.instanceId2)
    }
    
    override func tearDown() {
        TestHelper.clearEverything(instanceId: TestHelper.instanceId)
        TestHelper.clearEverything(instanceId: TestHelper.instanceId2)
        super.tearDown()
    }
       
    func testSetUserIdShouldNotAffectTheOther() {
        let tokenProvider1 = StubTokenProvider(jwt: validCucasToken, error: nil)
        let tokenProvider2 = StubTokenProvider(jwt: validJessToken, error: nil)
        
        let pni1 = PushNotifications(instanceId: TestHelper.instanceId)
        let pni2 = PushNotifications(instanceId: TestHelper.instanceId2)
        
        pni1.start()
        pni2.start()
        
        pni1.registerDeviceToken(validAPNsToken)
        pni2.registerDeviceToken(validAPNsToken)
        
        let expCucas = expectation(description: "Set user id for cucas should succeed")
        pni1.setUserId("cucas", tokenProvider: tokenProvider1) { error in
            XCTAssertNil(error)
            expCucas.fulfill()
        }
        waitForExpectations(timeout: 10)
        
        let expJess = expectation(description: "Set user id for jess should succeed")
        pni2.setUserId("jess", tokenProvider: tokenProvider2) { error in
            XCTAssertNil(error)
            expJess.fulfill()
        }
        waitForExpectations(timeout: 10)
        
        let deviceId1 = InstanceDeviceStateStore(TestHelper.instanceId).getDeviceId()!
        let deviceId2 = InstanceDeviceStateStore(TestHelper.instanceId2).getDeviceId()!

        expect(TestAPIClientHelper().getDevice(instanceId: TestHelper.instanceId, deviceId: deviceId1)?.userId)
            .toEventually(equal("cucas"), timeout: 30)
        expect(TestAPIClientHelper().getDevice(instanceId: TestHelper.instanceId2, deviceId: deviceId2)?.userId)
        .toEventually(equal("jess"), timeout: 30)
    }
    
    func testMultipleDeviceTokenRegistrationAffectsAllStartedInstances() {
        let pni1 = PushNotifications(instanceId: TestHelper.instanceId)
        let pni2 = PushNotifications(instanceId: TestHelper.instanceId2)
        
        pni1.start()
        pni2.start()
        
        pni1.registerDeviceToken(validAPNsToken)
        
        expect(InstanceDeviceStateStore(TestHelper.instanceId).getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        expect(InstanceDeviceStateStore(TestHelper.instanceId2).getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
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
