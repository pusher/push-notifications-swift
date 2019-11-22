import XCTest
@testable import PushNotifications

class ConstantsTests: XCTestCase {
    func testUserDefaultsConstants() {
        XCTAssertEqual(PersistenceConstants.UserDefaults.suiteName(instanceId: nil), "PushNotifications")
        XCTAssertEqual(PersistenceConstants.UserDefaults.suiteName(
            instanceId: "1b880590-6301-4bb5-b34f-45db1c5f5644"),
                       "PushNotifications.1b880590-6301-4bb5-b34f-45db1c5f5644")
        XCTAssertEqual(PersistenceConstants.UserDefaults.metadataSDKVersion, "com.pusher.sdk.metadata.sdkVersion")
        XCTAssertEqual(PersistenceConstants.UserDefaults.metadataiOSVersion, "com.pusher.sdk.metadata.iosVersion")
        XCTAssertEqual(PersistenceConstants.UserDefaults.metadataMacOSVersion, "com.pusher.sdk.metadata.macosVersion")
        XCTAssertEqual(PersistenceConstants.UserDefaults.deviceId, "com.pusher.sdk.deviceId")
        XCTAssertEqual(PersistenceConstants.UserDefaults.instanceId, "com.pusher.sdk.instanceId")
    }

    func testPersistanceServiceConstants() {
        XCTAssertEqual(PersistenceConstants.PersistenceService.prefix, "com.pusher.sdk.interests")
        XCTAssertEqual(PersistenceConstants.PersistenceService.hashKey, "interestsHash")
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

