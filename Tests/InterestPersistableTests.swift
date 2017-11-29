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
        let persistenceOperation = self.persistenceService.persist(interests: ["a", "b", "c", "d", "e"])
        XCTAssertTrue(persistenceOperation)
    }

    func testPersistInterestsThatAreAlreadySaved() {
        _ = self.persistenceService.persist(interests: ["a", "b", "c", "d", "e"])
        let persistenceOperation = self.persistenceService.persist(interests: ["a", "b", "c", "d", "e"])
        XCTAssertFalse(persistenceOperation)
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
        XCTAssertNil(interests)
    }

    func testGetSubscriptionsEmpty() {
        XCTAssertNil(self.persistenceService.getSubscriptions())
    }

    func testGetSubscriptions() {
        let interests = ["a", "b", "c", "d", "e"]
        _ = self.persistenceService.persist(interests: interests)
        guard let subscriptions = self.persistenceService.getSubscriptions() else {
            XCTFail()
            return
        }

        XCTAssertNotNil(subscriptions)
        XCTAssertEqual(subscriptions, interests)
    }
}
