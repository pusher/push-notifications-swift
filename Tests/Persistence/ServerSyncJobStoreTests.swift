import XCTest
@testable import PushNotifications

class ServerSyncJobStoreTests : XCTestCase {
    override func setUp() {
        super.setUp()
        TestHelper.clearEverything(instanceId: TestHelper.instanceId)
    }
    
    override func tearDown() {
        super.tearDown()
        TestHelper.clearEverything(instanceId: TestHelper.instanceId)
    }
    
    
    func testBasicOperations() {
        var jobstore = ServerSyncJobStore(instanceId: TestHelper.instanceId)

        XCTAssertTrue(jobstore.isEmpty)
        
        jobstore.append(.SetUserIdJob(userId: "danielle"))
            
        XCTAssertFalse(jobstore.isEmpty)
        
        let list = jobstore.toList()
        XCTAssertEqual(list.count, 1)
        
        if case .SetUserIdJob(let userId) = list[0] {
            XCTAssertEqual(userId, "danielle")
        } else {
            XCTFail()
        }
        
        if let firstElement = jobstore.first,
            case .SetUserIdJob(let userId) = firstElement {
            XCTAssertEqual(userId, "danielle")
        } else {
            XCTFail()
        }
        
        jobstore.removeFirst()
        
        XCTAssertTrue(jobstore.isEmpty)
        XCTAssertEqual(jobstore.toList().count, 0)
    }
    

    func testCorruptedFileShouldReturnEmptyOperations() {
        // create the file manually
        let url = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let filePath = url.appendingPathComponent("syncJobStore")
        let contents = "[invalid_json // lol]"
        FileManager.default.createFile(atPath: filePath.relativePath, contents: contents.toData()!)
        
        let jobstore = ServerSyncJobStore(instanceId: TestHelper.instanceId)
        
        XCTAssertTrue(jobstore.isEmpty)
        XCTAssertEqual(jobstore.toList().count, 0)
    }
    
    func testCorruptedEventShouldNotDropAllRequests() {
        let url = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let filePath = url.appendingPathComponent("\(TestHelper.instanceId)-syncJobStore")
        let contents = "[{\"userIdKey\":\"danielle\",\"discriminator\":6},{\"discriminator\":7000}]"
        FileManager.default.createFile(atPath: filePath.relativePath, contents: contents.data(using: .utf8)!)
        
        let jobstore = ServerSyncJobStore(instanceId: TestHelper.instanceId)
        XCTAssertFalse(jobstore.isEmpty)
        XCTAssertEqual(jobstore.toList().count, 1)
    }
    
    func testReportMissingInstanceIdEventShouldNotDropAllRequests() {
          let url = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
          let filePath = url.appendingPathComponent("\(TestHelper.instanceId)-syncJobStore")
          let contents = "[{\"userIdKey\":\"danielle\",\"discriminator\":6},{\"openEventTypeKey\":{\"deviceId\":\"192031231\",\"timestampSecs\":12,\"event\":\"Open\",\"publishId\":\"13u190231\"},\"discriminator\":7}]"
          FileManager.default.createFile(atPath: filePath.relativePath, contents: contents.data(using: .utf8)!)
          
          let jobstore = ServerSyncJobStore(instanceId: TestHelper.instanceId)
          XCTAssertFalse(jobstore.isEmpty)
          XCTAssertEqual(jobstore.toList().count, 1)
      }
}
