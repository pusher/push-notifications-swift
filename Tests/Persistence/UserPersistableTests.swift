import XCTest
@testable import PushNotifications

class UserPersistableTests: XCTestCase {

    var persistenceService: UserPersistable!

    override func setUp() {
            super.setUp()
            self.persistenceService = PersistenceService(service: UserDefaults(suiteName: "Test")!)
        }

    override func tearDown() {
            self.persistenceService = nil
            UserDefaults.standard.removePersistentDomain(forName: "Test")
            super.tearDown()
    }

    func testPersistUserThatWasNotSavedYet() {
        let userIdNotSetYet = self.persistenceService.getUserId()
        XCTAssertNil(userIdNotSetYet)
        let persistenceOperation = self.persistenceService.setUserId(userId: "Johnny Cash")
        XCTAssertTrue(persistenceOperation)
        let userId = self.persistenceService.getUserId()
        XCTAssertNotNil(userId)
        XCTAssertEqual(userId, "Johnny Cash")
    }

    func testPersistUserThatIsAlreadySaved() {
        _ = self.persistenceService.setUserId(userId: "Johnny Cash")
        let persistenceOperation = self.persistenceService.setUserId(userId: "Johnny Cash")
        XCTAssertFalse(persistenceOperation)
    }

    func testPersistUserAndRemoveUser() {
        let persistenceOperation = self.persistenceService.setUserId(userId: "Johnny Cash")
        XCTAssertTrue(persistenceOperation)
        let userId = self.persistenceService.getUserId()
        XCTAssertNotNil(userId)
        XCTAssertEqual(userId, "Johnny Cash")
        self.persistenceService.removeUserId()
        XCTAssertNil(self.persistenceService.getUserId())
    }
}
