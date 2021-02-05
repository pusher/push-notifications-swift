@testable import PushNotifications
import XCTest

class FeatureFlagsTests: XCTestCase {
    func testFeatureFlagDeliveryTrackingEnabledIsSetToTrue() {
        XCTAssertEqual(FeatureFlags.DeliveryTrackingEnabled, true)
    }
}
