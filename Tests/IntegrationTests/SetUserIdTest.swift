import XCTest
import Nimble
@testable import PushNotifications

class SetUserIdTest: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-SetUserIdTest".data(using: .utf8)!
    let validCucasJWTToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjQ3MDc5OTIzMDIsImlzcyI6Imh0dHBzOi8vMWI4ODA1OTAtNjMwMS00YmI1LWIzNGYtNDVkYjFjNWY1NjQ0LnB1c2hub3RpZmljYXRpb25zLnB1c2hlci5jb20iLCJzdWIiOiJjdWNhcyJ9.CTtrDXh7vae3rSSKBKf5X0y4RQpFg7YvIlirmBQqJn4"

    override func setUp() {
        if let deviceId = Device.getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    override func tearDown() {
        if let deviceId = Device.getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    func testSetUserIdShouldAssociateThisDeviceWithUserOnTheServer() {
        let pushNotifications = PushNotifications()
        pushNotifications.start(instanceId: instanceId)
        pushNotifications.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = Device.getDeviceId()!

        let tokenProvider = StubTokenProvider(jwt: validCucasJWTToken, error: nil)
        pushNotifications.setUserId("cucas", tokenProvider: tokenProvider) { _ in }

        expect(TestAPIClientHelper().getDevice(instanceId: self.instanceId, deviceId: deviceId)?.userId)
            .toEventually(equal("cucas"), timeout: 30)
    }

    func testSetUserIdShouldThrowExceptionIfUserIdIsReassigned() {
        let pushNotifications = PushNotifications()
        pushNotifications.start(instanceId: instanceId)
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
        let pushNotifications = PushNotifications()
        pushNotifications.start(instanceId: instanceId)
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
        let pushNotifications = PushNotifications()
        let exp = expectation(description: "It should return an error")
        let tokenProvider = StubTokenProvider(jwt: validCucasJWTToken, error: nil)
        pushNotifications.setUserId("cucas", tokenProvider: tokenProvider) { error in
            XCTAssertNotNil(error)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)
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
