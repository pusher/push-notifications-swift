import XCTest
import OHHTTPStubs
@testable import PushNotifications

class BeamsTokenProviderTests: XCTestCase {

    let instanceId = "8a070eaa-033f-46d6-bb90-f4c15acc47e1"
    let deviceId = "apns-8792dc3f-45ce-4fd9-ab6d-3bf731f813c6"
    var beamsTokenProvider: BeamsTokenProvider!

    override func setUp() {
        super.setUp()
        self.beamsTokenProvider = BeamsTokenProvider(authURL: "localhost:8080", getAuthData: { () -> (AuthData) in
            let sessionToken = "SESSION-TOKEN"
            return AuthData(headers: ["Authorization": "Bearer \(sessionToken)"], urlParams: [:])
        })
    }

    override func tearDown() {
        self.beamsTokenProvider = nil
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testBeamsTokenProvider() {
        XCTAssertNotNil(self.beamsTokenProvider.authURL)
        XCTAssertEqual(self.beamsTokenProvider.authURL, "localhost:8080")

        let url = self.authURL()
        let jsonObject: [String: Any] = [
            "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDA1NjA"
        ]
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }

        let exp = expectation(description: "It should successfully fetch the token")

        self.beamsTokenProvider.fetchToken(userId: "Johnny Cash") { (token, error) in
            guard error == nil else {
                XCTFail()
                return exp.fulfill()
            }

            XCTAssertNotNil(token)
            XCTAssertEqual(token, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDA1NjA")
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    func testBeamsTokenProviderInvalidToken() {
        let url = self.authURL()
        let responseToken = ""
        let stubData = responseToken.data(using: .utf8)
        stub(condition: isAbsoluteURLString(url.absoluteString)) { _ in
            return OHHTTPStubsResponse(data: stubData!, statusCode: 500, headers: nil)
        }

        let exp = expectation(description: "It should return an error.")

        self.beamsTokenProvider.fetchToken(userId: "Johnny Cash") { (token, error) in
            guard error == nil else {
                XCTAssertNotNil(error)
                return exp.fulfill()
            }

            XCTFail()
            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }

    private func authURL() -> URL {
        let testURLString = "localhost:8080"
        var components = URLComponents(string: testURLString)!
        let userIdQueryItem = URLQueryItem(name: "user_id", value: "Johnny Cash")
        components.queryItems = [userIdQueryItem]

        return components.url!
    }
}
