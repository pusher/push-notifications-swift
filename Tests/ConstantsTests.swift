import XCTest
@testable import PushNotifications

class ConstantsTests: XCTestCase {
    func testUserDefaultsConstants() {
        XCTAssertEqual(Constants.UserDefaults.suiteName, "PushNotifications")
        XCTAssertEqual(Constants.UserDefaults.metadataSDKVersion, "com.pusher.sdk.metadata.sdkVersion")
        XCTAssertEqual(Constants.UserDefaults.metadataiOSVersion, "com.pusher.sdk.metadata.iosVersion")
        XCTAssertEqual(Constants.UserDefaults.metadataMacOSVersion, "com.pusher.sdk.metadata.macosVersion")
        XCTAssertEqual(Constants.UserDefaults.deviceId, "com.pusher.sdk.deviceId")
        XCTAssertEqual(Constants.UserDefaults.instanceId, "com.pusher.sdk.instanceId")
    }

    func testPersistanceServiceConstants() {
        XCTAssertEqual(Constants.PersistanceService.prefix, "com.pusher.sdk.interests")
        XCTAssertEqual(Constants.PersistanceService.hashKey, "interestsHash")
    }

    func testDispatchQueueConstants() {
        XCTAssertEqual(Constants.DispatchQueue.preIISOperationQueue, "com.pusher.pushnotifications.pre.iis.operation.queue")
        XCTAssertEqual(Constants.DispatchQueue.persistenceStorageOperationQueue, "com.pusher.pushnotifications.persistence.storage.operation.queue")
    }

    func testReportEventTypeConstants() {
        XCTAssertEqual(Constants.ReportEventType.open, "Open")
        XCTAssertEqual(Constants.ReportEventType.delivery, "Delivery")
    }
}

