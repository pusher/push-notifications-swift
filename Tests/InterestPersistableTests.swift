import XCTest
@testable import PushNotifications

class InterestPersistableTests: XCTestCase {

    var persistenceService: InterestPersistable!

    override func setUp() {
        super.setUp()
        self.persistenceService = PersistenceService(service: UserDefaults(suiteName: "Test")!)
    }
    
    override func tearDown() {
        self.persistenceService = nil
        UserDefaults.standard.removePersistentDomain(forName: "Test")
        super.tearDown()
    }
    
    func testPersistInterestThatWasNotSavedYet() {
        let persistenceOperation = self.persistenceService.persist(interest: "tech")
        XCTAssertTrue(persistenceOperation)
    }

    func testPersistInterestThatIsAlreadySaved() {
        _ = self.persistenceService.persist(interest: "tech")
        let persistenceOperation = self.persistenceService.persist(interest: "tech")
        XCTAssertFalse(persistenceOperation)
    }

    func testPersistInterestsThatWereNotSavedYet() {
        let interests = ["a", "b", "c", "d", "e"]
        self.persistenceService.persist(interests: interests)
        let storedInterests = self.persistenceService.getSubscriptions()
        XCTAssertNotNil(storedInterests!)
        XCTAssertTrue(interests.containsSameElements(as: storedInterests!))
    }

    func testRemoveInterestFromTheStorage() {
        let removeOperation = self.persistenceService.remove(interest: "tech")
        XCTAssertFalse(removeOperation)
    }

    func testRemoveExistingInterestFromTheStorage() {
        _ = self.persistenceService.persist(interest: "tech")
        let removeOperation = self.persistenceService.remove(interest: "tech")
        XCTAssertTrue(removeOperation)
    }

    func testRemoveAllInterests() {
        _ = self.persistenceService.persist(interests: ["a", "b", "c", "d", "e"])
        self.persistenceService.removeAll()
        let interests = self.persistenceService.getSubscriptions()
        XCTAssertEqual(interests!, [])
    }
    
    func testPersistInterestAndBatchSaveInterests() {
        let persistenceOperation = self.persistenceService.persist(interest: "interest")
        XCTAssertTrue(persistenceOperation)
        let interests = ["a", "b", "c", "d", "e"]
        self.persistenceService.persist(interests: interests)
        let storedInterests = self.persistenceService.getSubscriptions()
        XCTAssertNotNil(storedInterests!)
        XCTAssert(storedInterests?.count == 5)
        XCTAssertTrue(interests.containsSameElements(as: storedInterests!))
    }
    
    func testBatchSaveInterestsAndPersistAnotherInterest() {
        let interests = ["a", "b", "c", "d", "e"]
        self.persistenceService.persist(interests: interests)
        let persistenceOperation = self.persistenceService.persist(interest: "interest")
        let storedInterests = self.persistenceService.getSubscriptions()
        XCTAssertNotNil(storedInterests!)
        XCTAssertTrue(persistenceOperation)
        XCTAssert(storedInterests?.count == 6)
    }
}
