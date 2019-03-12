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
        self.persistenceService.removeAllSubscriptions()
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
        XCTAssertTrue(storedInterests!.containsSameElements(as: ["a", "b", "c", "d", "e", "interest"]))
    }

    func testBatchSaveInterestsAndSaveExistingInterest() {
        let interests = ["a", "b", "c"]
        self.persistenceService.persist(interests: interests)
        let persistenceOperation = self.persistenceService.persist(interest: "a")
        XCTAssertFalse(persistenceOperation)
        let storedInterests = self.persistenceService.getSubscriptions()
        XCTAssert(storedInterests?.count == 3)
        XCTAssertTrue(storedInterests!.containsSameElements(as: interests))
    }

    func testBatchSaveSameInterestsTwice() {
        let interests = ["a", "b", "c"]
        let persistenceOperation = self.persistenceService.persist(interests: interests)
        XCTAssertTrue(persistenceOperation)
        let persistSameInterestSetAgain = self.persistenceService.persist(interests: interests)
        XCTAssertFalse(persistSameInterestSetAgain)
    }

    func testPersistInterestWithALongName() {
        let interestWithALongName = "cs3pbizT,UjWwYXfguIm@y=l730QOOJvPfWV@W0_h2_IO8mkEzeS1JXwC@nHJDuZwbrgtsCVXAA3=9CIkQW69,.4d6Cs5Ny_gRALxAj3YlXEk674SGiqWgX:T74M6yQAqWfSGSJT.unKgg3J0ZqiQng__2V8ladmfVNw"
        let persistenceOperation = self.persistenceService.persist(interest: interestWithALongName)
        XCTAssertTrue(persistenceOperation)
        let storedInterests = self.persistenceService.getSubscriptions()
        XCTAssertNotNil(storedInterests!)
        XCTAssertTrue(storedInterests?.count == 1)
        XCTAssertTrue(storedInterests!.containsSameElements(as: [interestWithALongName]))
    }

    func testInterestsHash() {
        self.persistenceService.persistServerConfirmedInterestsHash("749e2830366ba863f796cdf5e281662f")

        XCTAssertEqual(self.persistenceService.getServerConfirmedInterestsHash(), "749e2830366ba863f796cdf5e281662f")
    }

    func testNilInterestsHash() {
        XCTAssertEqual(self.persistenceService.getServerConfirmedInterestsHash(), "")
    }
}
