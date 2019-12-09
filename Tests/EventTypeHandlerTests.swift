import XCTest
@testable import PushNotifications

class EventTypeHandlerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // we extract the device id when parsing events, we need to make sure this exists for all the tests
        InstanceDeviceStateStore(TestHelper.instanceId).persistDeviceId("abcd")
    }
    
    override func tearDown() {
        InstanceDeviceStateStore(TestHelper.instanceId).deleteDeviceId()
        super.tearDown()
    }

    #if os(iOS)
    func testEventTypeActive() {
        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active) as! DeliveryEventType

        XCTAssertTrue(eventType.event == Constants.ReportEventType.delivery)
        XCTAssertFalse(eventType.appInBackground)
        XCTAssertFalse(eventType.hasDisplayableContent)
        XCTAssertFalse(eventType.hasData)
    }

    func testUserIdNotEmpty() {
        let deviceStateStore = InstanceDeviceStateStore(TestHelper.instanceId)
        XCTAssertTrue(deviceStateStore.persistUserId(userId: "denis-s"))

        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active) as! DeliveryEventType
        XCTAssertNotNil(eventType.userId)
        XCTAssertEqual(eventType.userId, "denis-s")
    }

    func testUserIdEmpty() {
        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df", "userId": nil]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active) as! DeliveryEventType
        XCTAssertNil(eventType.userId)
        XCTAssertEqual(eventType.userId, nil)
    }

    func testEventTypeActiveWithDisplayableContent() {
        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active) as! DeliveryEventType

        XCTAssertTrue(eventType.event == Constants.ReportEventType.delivery)
        XCTAssertFalse(eventType.appInBackground)
        XCTAssertTrue(eventType.hasDisplayableContent)
        XCTAssertFalse(eventType.hasData)
    }

    func testEventTypeActiveWithDisplayableContentAndData() {
        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"], "acme2": [ "bang", "whiz"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active) as! DeliveryEventType

        XCTAssertTrue(eventType.event == Constants.ReportEventType.delivery)
        XCTAssertFalse(eventType.appInBackground)
        XCTAssertTrue(eventType.hasDisplayableContent)
        XCTAssertTrue(eventType.hasData)
    }

    func testEventTypeBackground() {
        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .background) as! DeliveryEventType

        XCTAssertTrue(eventType.event == Constants.ReportEventType.delivery)
        XCTAssertTrue(eventType.appInBackground)
        XCTAssertFalse(eventType.hasDisplayableContent)
        XCTAssertFalse(eventType.hasData)
    }

    func testEventTypeBackgroundWithDisplayableContent() {
        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .background) as! DeliveryEventType

        XCTAssertTrue(eventType.event == Constants.ReportEventType.delivery)
        XCTAssertTrue(eventType.appInBackground)
        XCTAssertTrue(eventType.hasDisplayableContent)
        XCTAssertFalse(eventType.hasData)
    }

    func testEventTypeBackgroundWithDisplayableContentAndData() {
        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"], "acme2": [ "bang", "whiz"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .background) as! DeliveryEventType

        XCTAssertTrue(eventType.event == Constants.ReportEventType.delivery)
        XCTAssertTrue(eventType.appInBackground)
        XCTAssertTrue(eventType.hasDisplayableContent)
        XCTAssertTrue(eventType.hasData)
    }

    func testEventTypeInactive() {
        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .inactive) as! OpenEventType

        XCTAssertTrue(eventType.event == Constants.ReportEventType.open)
    }
    #elseif os(OSX)
    func testEventTypeOpen() {
        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        guard let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo) else {
            return XCTFail()
        }

        XCTAssertTrue(eventType.event == Constants.ReportEventType.open)
    }

    func testUserIdNotEmpty() {
        let deviceStateStore = InstanceDeviceStateStore(TestHelper.instanceId)
        XCTAssertTrue(deviceStateStore.persistUserId(userId: "denis-s"))

        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        guard let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo) else {
            return XCTFail()
        }

        XCTAssertNotNil(eventType.userId)
        XCTAssertEqual(eventType.userId, "denis-s")
    }

    func testUserIdEmpty() {
        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df", "userId": nil]]]
        guard let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo) else {
            return XCTFail()
        }
        XCTAssertNil(eventType.userId)
        XCTAssertEqual(eventType.userId, nil)
    }

    func testItIsInternalNotification() {
        let userInfo = ["aps" : ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df", "userShouldIgnore": true]]]

        let remoteNotificationType = EventTypeHandler.getRemoteNotificationType(userInfo)
        XCTAssertTrue(remoteNotificationType == .ShouldIgnore)
    }

    func testItIsNotInternalNotification() {
        let userInfo = ["aps" : ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]

        let remoteNotificationType = EventTypeHandler.getRemoteNotificationType(userInfo)
        XCTAssertTrue(remoteNotificationType == .ShouldProcess)
    }
    
    func testMissingInstanceIdReturnsNil() {
        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df", "userId": nil]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo)
        XCTAssertNil(eventType)
    }
    
    func testMissingPublishIdReturnsNil() {
        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["instanceId": "1b880590-6301-4bb5-b34f-45db1c5f5644", "userId": nil]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo)
        XCTAssertNil(eventType)
    }
    #endif
}
