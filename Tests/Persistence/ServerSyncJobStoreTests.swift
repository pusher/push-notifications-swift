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
        var jobstore = ServerSyncJobStore()

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
        
        let firstElement = jobstore.first
        if case .SetUserIdJob(let userId) = firstElement {
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
        try? FileManager.default.createFile(atPath: filePath.relativePath, contents: contents.toData()!)
        
        let jobstore = ServerSyncJobStore()
        
        XCTAssertTrue(jobstore.isEmpty)
        XCTAssertEqual(jobstore.toList().count, 0)
    }
    
    func testCorruptedEventShouldDropAllRequests() {
        let url = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let filePath = url.appendingPathComponent("syncJobStore")
        let contents = "[{\"userIdKey\":\"danielle\",\"discriminator\":6},{\"discriminator\":7000}]"
        try? FileManager.default.createFile(atPath: filePath.relativePath, contents: contents.toData()!)
        
        var jobstore = ServerSyncJobStore()
        XCTAssertTrue(jobstore.isEmpty)
        XCTAssertEqual(jobstore.toList().count, 0)
    }
    
}
