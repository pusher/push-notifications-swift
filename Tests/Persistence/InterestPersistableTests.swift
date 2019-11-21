import XCTest
@testable import PushNotifications

class InterestPersistableTests: XCTestCase {

    var persistenceService: DeviceStateStore!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: PersistenceConstants.UserDefaults.suiteName)
        self.persistenceService = DeviceStateStore()
    }

    override func tearDown() {
        self.persistenceService = nil
        UserDefaults.standard.removePersistentDomain(forName: PersistenceConstants.UserDefaults.suiteName)
        super.tearDown()
    }

    func testPersistInterestThatWasNotSavedYet() {
        let persistenceOperation = self.persistenceService.persistInterest("tech")
        XCTAssertTrue(persistenceOperation)
    }

    func testPersistInterestThatIsAlreadySaved() {
        _ = self.persistenceService.persistInterest("tech")
        let persistenceOperation = self.persistenceService.persistInterest("tech")
        XCTAssertFalse(persistenceOperation)
    }

    func testPersistInterestsThatWereNotSavedYet() {
        let interests = ["a", "b", "c", "d", "e"]
        self.persistenceService.persistInterests(interests)
        let storedInterests = self.persistenceService.getInterests()
        XCTAssertNotNil(storedInterests!)
        XCTAssertTrue(interests.containsSameElements(as: storedInterests!))
    }

    func testRemoveInterestFromTheStorage() {
        let removeOperation = self.persistenceService.removeInterest(interest: "tech")
        XCTAssertFalse(removeOperation)
    }

    func testRemoveExistingInterestFromTheStorage() {
        _ = self.persistenceService.persistInterest("tech")
        let removeOperation = self.persistenceService.removeInterest(interest: "tech")
        XCTAssertTrue(removeOperation)
    }

    func testRemoveAllInterests() {
        _ = self.persistenceService.persistInterests(["a", "b", "c", "d", "e"])
        self.persistenceService.removeAllInterests()
        let interests = self.persistenceService.getInterests()
        XCTAssertEqual(interests!, [])
    }

    func testPersistInterestAndBatchSaveInterests() {
        let persistenceOperation = self.persistenceService.persistInterest("interest")
        XCTAssertTrue(persistenceOperation)
        let interests = ["a", "b", "c", "d", "e"]
        self.persistenceService.persistInterests(interests)
        let storedInterests = self.persistenceService.getInterests()
        XCTAssertNotNil(storedInterests!)
        XCTAssert(storedInterests?.count == 5)
        XCTAssertTrue(interests.containsSameElements(as: storedInterests!))
    }

    func testBatchSaveInterestsAndPersistAnotherInterest() {
        let interests = ["a", "b", "c", "d", "e"]
        self.persistenceService.persistInterests(interests)
        let persistenceOperation = self.persistenceService.persistInterest("interest")
        let storedInterests = self.persistenceService.getInterests()
        XCTAssertNotNil(storedInterests!)
        XCTAssertTrue(persistenceOperation)
        XCTAssert(storedInterests?.count == 6)
        XCTAssertTrue(storedInterests!.containsSameElements(as: ["a", "b", "c", "d", "e", "interest"]))
    }

    func testBatchSaveInterestsAndSaveExistingInterest() {
        let interests = ["a", "b", "c"]
        self.persistenceService.persistInterests(interests)
        let persistenceOperation = self.persistenceService.persistInterest("a")
        XCTAssertFalse(persistenceOperation)
        let storedInterests = self.persistenceService.getInterests()
        XCTAssert(storedInterests?.count == 3)
        XCTAssertTrue(storedInterests!.containsSameElements(as: interests))
    }

    func testBatchSaveSameInterestsTwice() {
        let interests = ["a", "b", "c"]
        let persistenceOperation = self.persistenceService.persistInterests(interests)
        XCTAssertTrue(persistenceOperation)
        let persistSameInterestSetAgain = self.persistenceService.persistInterests(interests)
        XCTAssertFalse(persistSameInterestSetAgain)
    }

    func testPersistInterestWithALongName() {
        let interestWithALongName = "cs3pbizT,UjWwYXfguIm@y=l730QOOJvPfWV@W0_h2_IO8mkEzeS1JXwC@nHJDuZwbrgtsCVXAA3=9CIkQW69,.4d6Cs5Ny_gRALxAj3YlXEk674SGiqWgX:T74M6yQAqWfSGSJT.unKgg3J0ZqiQng__2V8ladmfVNw"
        let persistenceOperation = self.persistenceService.persistInterest(interestWithALongName)
        XCTAssertTrue(persistenceOperation)
        let storedInterests = self.persistenceService.getInterests()
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
