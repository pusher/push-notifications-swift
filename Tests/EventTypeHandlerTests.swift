#if os(iOS)
import XCTest
@testable import PushNotifications

class EventTypeHandlerTests: XCTestCase {
    func testEventTypeActive() {
        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active) as! DeliveryEventType

        XCTAssertTrue(eventType.eventId == "Delivery")
        XCTAssertFalse(eventType.appInBackground)
        XCTAssertFalse(eventType.hasDisplayableContent)
        XCTAssertFalse(eventType.hasData)
    }

    func testEventTypeActiveWithDisplayableContent() {
        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active) as! DeliveryEventType

        XCTAssertTrue(eventType.eventId == "Delivery")
        XCTAssertFalse(eventType.appInBackground)
        XCTAssertTrue(eventType.hasDisplayableContent)
        XCTAssertFalse(eventType.hasData)
    }

    func testEventTypeActiveWithDisplayableContentAndData() {
        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"], "acme2": [ "bang", "whiz"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .active) as! DeliveryEventType

        XCTAssertTrue(eventType.eventId == "Delivery")
        XCTAssertFalse(eventType.appInBackground)
        XCTAssertTrue(eventType.hasDisplayableContent)
        XCTAssertTrue(eventType.hasData)
    }

    func testEventTypeBackground() {
        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .background) as! DeliveryEventType

        XCTAssertTrue(eventType.eventId == "Delivery")
        XCTAssertTrue(eventType.appInBackground)
        XCTAssertFalse(eventType.hasDisplayableContent)
        XCTAssertFalse(eventType.hasData)
    }

    func testEventTypeBackgroundWithDisplayableContent() {
        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .background) as! DeliveryEventType

        XCTAssertTrue(eventType.eventId == "Delivery")
        XCTAssertTrue(eventType.appInBackground)
        XCTAssertTrue(eventType.hasDisplayableContent)
        XCTAssertFalse(eventType.hasData)
    }

    func testEventTypeBackgroundWithDisplayableContentAndData() {
        let userInfo = ["aps": ["alert": ["title": "Hello", "body": "Hello, world!"], "content-available": 1], "data": ["pusher": ["publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"], "acme2": [ "bang", "whiz"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .background) as! DeliveryEventType

        XCTAssertTrue(eventType.eventId == "Delivery")
        XCTAssertTrue(eventType.appInBackground)
        XCTAssertTrue(eventType.hasDisplayableContent)
        XCTAssertTrue(eventType.hasData)
    }

    func testEventTypeInactive() {
        let userInfo = ["aps": ["content-available": 1], "data": ["pusher": ["publishId": "pubid-33f3f68e-b0c5-438f-b50f-fae93f6c48df"]]]
        let eventType = EventTypeHandler.getNotificationEventType(userInfo: userInfo, applicationState: .inactive)!

        XCTAssertTrue(eventType.eventId == "Open")
    }
}
#endif
