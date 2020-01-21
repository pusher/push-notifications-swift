import XCTest
@testable import PushNotifications

class InstanceDeviceStateStoreTests : XCTestCase {
    
    let instanceDeviceStateStore1 = InstanceDeviceStateStore("instanceId1")
    let instanceDeviceStateStore2 = InstanceDeviceStateStore("instanceId2")
    
    override func setUp() {
        super.setUp()
        instanceDeviceStateStore1.clear()
        instanceDeviceStateStore2.clear()
    }
    
    override func tearDown() {
        instanceDeviceStateStore1.clear()
        instanceDeviceStateStore2.clear()
        super.tearDown()
    }
    
    
    func testTwoInstancesDoNotIntefere() {
        // set 1 instance up with some interests and a device
        _ = instanceDeviceStateStore1.persistInterests(["cat", "dog"])
        instanceDeviceStateStore1.persistDeviceId("deviceId1")
        
        // set 2nd instance up with different interests and a device
        _ = instanceDeviceStateStore2.persistInterests(["banana", "apple", "pear"])
        instanceDeviceStateStore2.persistDeviceId("deviceId2")
        
        // check they're saved
        XCTAssertTrue((instanceDeviceStateStore1.getInterests()?.containsSameElements(as: ["cat", "dog"]))!)
        XCTAssertTrue((instanceDeviceStateStore2.getInterests()?.containsSameElements(as: ["banana", "apple", "pear"]))!)
        
        XCTAssertEqual(instanceDeviceStateStore1.getDeviceId(), "deviceId1")
        XCTAssertEqual(instanceDeviceStateStore2.getDeviceId(), "deviceId2")
        
        // clear instance 1
        instanceDeviceStateStore1.clear()
        
        // check instance 1 is cleared and instance 2 is still okay
        XCTAssertEqual(instanceDeviceStateStore1.getInterests(), [])
        XCTAssertTrue((instanceDeviceStateStore2.getInterests()?.containsSameElements(as: ["banana", "apple", "pear"]))!)
        
        XCTAssertEqual(instanceDeviceStateStore1.getDeviceId(), nil)
        XCTAssertEqual(instanceDeviceStateStore2.getDeviceId(), "deviceId2")
    }
}
