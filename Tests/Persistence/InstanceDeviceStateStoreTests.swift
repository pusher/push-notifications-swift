import XCTest
@testable import PushNotifications

class InstanceDeviceStateStoreTests : XCTestCase {
    
    let instanceDeviceStateStore1 = InstanceDeviceStateStore("instanceId1")
    let instanceDeviceStateStore2 = InstanceDeviceStateStore("instanceId2")
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        instanceDeviceStateStore1.clear()
        instanceDeviceStateStore2.clear()
        super.tearDown()
    }
    
    
    func testTwoInstancesDoNotIntefere() {
        // set 1 instance up with some interests
        instanceDeviceStateStore1.persistInterests(["cat", "dog"])
        
        // set 2nd instance up with different interests
        instanceDeviceStateStore2.persistInterests(["banana", "apple", "pear"])
        
        // check they're intefering
        XCTAssertTrue((instanceDeviceStateStore1.getInterests()?.containsSameElements(as: ["cat", "dog"]))!)
        XCTAssertTrue((instanceDeviceStateStore2.getInterests()?.containsSameElements(as: ["banana", "apple", "pear"]))!)
        
        // clear instance 1
        instanceDeviceStateStore1.clear()
        
        // check instance 2 is okay
        XCTAssertEqual(instanceDeviceStateStore1.getInterests(), [])
        XCTAssertTrue((instanceDeviceStateStore2.getInterests()?.containsSameElements(as: ["banana", "apple", "pear"]))!)
    }
    
    
}
