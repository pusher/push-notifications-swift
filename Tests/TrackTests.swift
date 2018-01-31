import XCTest
@testable import PushNotifications

class TrackTests: XCTestCase {
    let track: Track = Track(publishId: "123", timestampMs: 123456789)

    func testTrackModel() {
        let track = self.track
        XCTAssertNotNil(track)
        XCTAssertEqual(track.publishId, "123")
        XCTAssertEqual(track.timestampMs, 123456789)
    }

    func testTrackEncoded() {
        let trackEncoded = try! self.track.encode()
        XCTAssertNotNil(trackEncoded)
        let trackJSONExpected = "{\"timestampMs\":123456789,\"publishId\":\"123\"}"
        let trackJSON = String(data: trackEncoded, encoding: .utf8)!
        XCTAssertEqual(trackJSONExpected, trackJSON)
    }
}
