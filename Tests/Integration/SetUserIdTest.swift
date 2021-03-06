import Nimble
@testable import PushNotifications
import XCTest

class SetUserIdTest: XCTestCase {
    // Real production instance.
    private let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    private let validToken = "notadevicetoken-apns-SetUserIdTest".data(using: .utf8)!
    private let validCucasJWTToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjQ3MDc5OTIzMDIsImlzcyI6Imh0dHBzOi8vMWI4ODA1OTAtNjMwMS00YmI1LWIzNGYtNDVkYjFjNWY1NjQ0LnB1c2hub3RpZmljYXRpb25zLnB1c2hlci5jb20iLCJzdWIiOiJjdWNhcyJ9.CTtrDXh7vae3rSSKBKf5X0y4RQpFg7YvIlirmBQqJn4"

    override func setUp() {
        super.setUp()
        TestHelper.clearEverything(instanceId: instanceId)
    }

    override func tearDown() {
        TestHelper.clearEverything(instanceId: instanceId)
        super.tearDown()
    }

    func testSetUserIdShouldAssociateThisDeviceWithUserOnTheServer() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        expect(InstanceDeviceStateStore(self.instanceId).getDeviceId()).toEventuallyNot(beNil(), timeout: .seconds(10))
        let deviceId = InstanceDeviceStateStore(self.instanceId).getDeviceId()!

        let tokenProvider = StubTokenProvider(jwt: validCucasJWTToken, error: nil)
        pushNotifications.setUserId("cucas", tokenProvider: tokenProvider) { _ in }

        expect(TestAPIClientHelper().getDevice(instanceId: self.instanceId, deviceId: deviceId)?.userId)
            .toEventually(equal("cucas"), timeout: .seconds(30))
    }

    func testSetUserIdShouldThrowExceptionIfUserIdIsReassigned() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)
        let expCucas = expectation(description: "Set user id for cucas should succeed")
        let expPotato = expectation(description: "Set user id for potato should fail")

        let tokenProvider = StubTokenProvider(jwt: validCucasJWTToken, error: nil)
        pushNotifications.setUserId("cucas", tokenProvider: tokenProvider) { error in
            XCTAssertNil(error)
            expCucas.fulfill()
        }

        pushNotifications.setUserId("potato", tokenProvider: tokenProvider) { error in
            XCTAssertNotNil(error)
            expPotato.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testSetUserIdCallStopAndSettingADifferentUserIdSucceeds() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        pushNotifications.start()
        pushNotifications.registerDeviceToken(validToken)

        let tokenProvider = StubTokenProvider(jwt: validCucasJWTToken, error: nil)
        pushNotifications.setUserId("cucas", tokenProvider: tokenProvider) { error in
            XCTAssertNil(error)
        }

        pushNotifications.clearAllState { }

        let exp = expectation(description: "It should not return an error")
        pushNotifications.setUserId("potato", tokenProvider: tokenProvider) { error in
            XCTAssertNil(error)
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testSetUserIdShouldReturnErrorIfStartHasNotBeenCalled() {
        let pushNotifications = PushNotifications(instanceId: instanceId)
        let exp = expectation(description: "It should return an error")
        let tokenProvider = StubTokenProvider(jwt: validCucasJWTToken, error: nil)
        pushNotifications.setUserId("cucas", tokenProvider: tokenProvider) { error in
            XCTAssertNotNil(error)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    private class StubTokenProvider: TokenProvider {
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
