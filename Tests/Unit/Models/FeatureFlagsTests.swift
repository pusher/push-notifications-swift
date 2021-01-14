import XCTest
@testable import PushNotifications

class FeatureFlagsTests: XCTestCase {
    func testFeatureFlagDeliveryTrackingEnabledIsSetToTrue() {
        XCTAssertEqual(FeatureFlags.DeliveryTrackingEnabled, true)
    }
}
