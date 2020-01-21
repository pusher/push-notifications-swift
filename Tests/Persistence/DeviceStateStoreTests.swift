import XCTest
@testable import PushNotifications

class DeviceStateStoreTests : XCTestCase {
    override func setUp() {
        super.setUp()
        TestHelper.clearEverything(instanceId: TestHelper.instanceId)
    }
    
    override func tearDown() {
        super.tearDown()
        TestHelper.clearEverything(instanceId: TestHelper.instanceId)
    }
    
    func testInstanceIdsShouldRetrieveAndStoreInstancesCorrectly() {
        let deviceStateStore = DeviceStateStore()
        XCTAssertEqual(deviceStateStore.getInstanceIds(), [])
        
        deviceStateStore.persistInstanceId(TestHelper.instanceId)
        XCTAssertTrue(deviceStateStore.getInstanceIds().containsSameElements(as: [TestHelper.instanceId]))
        XCTAssertEqual(deviceStateStore.getInstanceIds().count, 1)
        
        // does not have duplicates
        deviceStateStore.persistInstanceId(TestHelper.instanceId)
        XCTAssertTrue(deviceStateStore.getInstanceIds().containsSameElements(as: [TestHelper.instanceId]))
        XCTAssertEqual(deviceStateStore.getInstanceIds().count, 1)
        
        // add another instance id
        deviceStateStore.persistInstanceId(TestHelper.instanceId2)
        XCTAssertTrue(deviceStateStore.getInstanceIds().containsSameElements(as: [TestHelper.instanceId, TestHelper.instanceId2]))
        XCTAssertEqual(deviceStateStore.getInstanceIds().count, 2)
        
        // remove first instance id
        deviceStateStore.removeInstanceId(instanceId: TestHelper.instanceId)
        XCTAssertTrue(deviceStateStore.getInstanceIds().containsSameElements(as: [TestHelper.instanceId2]))
        XCTAssertEqual(deviceStateStore.getInstanceIds().count, 1)
        
        // clear all instances
        deviceStateStore.removeAllInstanceIds()
        XCTAssertEqual(deviceStateStore.getInstanceIds(), [])
    }
    
    func testInstnaceIdsShouldMigrateCorrectly() {
        let oldInstanceService = UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName(instanceId: nil))!
        oldInstanceService.set(TestHelper.instanceId, forKey: PersistenceConstants.UserDefaults.instanceId)
        
        // save things to the old storage
        let oldInstanceStorage = InstanceDeviceStateStore(nil)
        _ = oldInstanceStorage.persistInterests(["lemon", "pomelo", "grapefruit"])
        _ = oldInstanceStorage.persistUserId(userId: "danielle")
        oldInstanceStorage.persistServerConfirmedInterestsHash("hash12345")
        oldInstanceStorage.persistStartJobHasBeenEnqueued(flag: true)
        oldInstanceStorage.persistUserIdHasBeenCalledWith(userId: "danielleHasBeenCalled")
        oldInstanceStorage.persistDeviceId("daniellesDeviceId")
        oldInstanceStorage.persistAPNsToken(token: "daniellesAPNsToken")
        oldInstanceStorage.persistMetadata(metadata: Metadata(sdkVersion: "123", iosVersion: "10.0", macosVersion: nil))
        
        // get from the new device state store which should handle the migration for us
        let deviceStateStore = DeviceStateStore()
        XCTAssertTrue(deviceStateStore.getInstanceIds().containsSameElements(as: [TestHelper.instanceId]))
        XCTAssertEqual(deviceStateStore.getInstanceIds().count, 1)
        
        // assert that the instance storage migrated correctly
        let newInstanceStorage = InstanceDeviceStateStore(TestHelper.instanceId)
        XCTAssertTrue(newInstanceStorage.getInterests()!.containsSameElements(as: ["lemon", "pomelo", "grapefruit"]))
        XCTAssertEqual(newInstanceStorage.getInterests()!.count, 3)
        XCTAssertEqual(newInstanceStorage.getUserId(), "danielle")
        XCTAssertEqual(newInstanceStorage.getServerConfirmedInterestsHash(), "hash12345")
        XCTAssertEqual(newInstanceStorage.getStartJobHasBeenEnqueued(), true)
        XCTAssertEqual(newInstanceStorage.getUserIdHasBeenCalledWith(), "danielleHasBeenCalled")
        XCTAssertEqual(newInstanceStorage.getDeviceId(), "daniellesDeviceId")
        XCTAssertEqual(newInstanceStorage.getAPNsToken(), "daniellesAPNsToken")
        XCTAssertEqual(newInstanceStorage.getMetadata().sdkVersion, "123")
        XCTAssertEqual(newInstanceStorage.getMetadata().iosVersion, "10.0")
        XCTAssertEqual(newInstanceStorage.getMetadata().macosVersion, nil)
        
        // assert that old reference is gone
        XCTAssertEqual(oldInstanceService.string(forKey: PersistenceConstants.UserDefaults.instanceId), nil)
    }
}
