import XCTest
@testable import PushNotifications

class FeatureFlagsTests: XCTestCase {
    func testFeatureFlagDeliveryTrackingEnabledIsSetToFalse() {
        XCTAssertEqual(FeatureFlags.DeliveryTrackingEnabled, false)
    }
}
