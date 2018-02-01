import XCTest
@testable import PushNotifications

class TrackTests: XCTestCase {
    let track: Track = Track(publishId: "123", timestampMs: 123456789, eventType: "Delivery", deviceId: "123")

    func testTrackModel() {
        let track = self.track
        XCTAssertNotNil(track)
        XCTAssertEqual(track.publishId, "123")
        XCTAssertEqual(track.timestampMs, 123456789)
        XCTAssertEqual(track.eventType, "Delivery")
        XCTAssertEqual(track.deviceId, "123")
    }

    func testTrackEncoded() {
        let trackEncoded = try! self.track.encode()
        XCTAssertNotNil(trackEncoded)
        let trackJSONExpected = "{\"deviceId\":\"123\",\"eventType\":\"Delivery\",\"publishId\":\"123\",\"timestampMs\":123456789}"
        let trackJSON = String(data: trackEncoded, encoding: .utf8)!
        XCTAssertEqual(trackJSONExpected, trackJSON)
    }
}
