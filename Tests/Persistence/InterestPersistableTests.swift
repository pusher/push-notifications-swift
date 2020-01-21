import XCTest
@testable import PushNotifications

class InterestPersistableTests: XCTestCase {

    var deviceStateStore: InstanceDeviceStateStore!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: PersistenceConstants.UserDefaults.suiteName(instanceId: TestHelper.instanceId))
        self.deviceStateStore = InstanceDeviceStateStore(TestHelper.instanceId)
    }

    override func tearDown() {
        self.deviceStateStore = nil
        UserDefaults.standard.removePersistentDomain(forName: PersistenceConstants.UserDefaults.suiteName(instanceId: TestHelper.instanceId))
        super.tearDown()
    }

    func testPersistInterestThatWasNotSavedYet() {
        let persistenceOperation = self.deviceStateStore.persistInterest("tech")
        XCTAssertTrue(persistenceOperation)
    }

    func testPersistInterestThatIsAlreadySaved() {
        _ = self.deviceStateStore.persistInterest("tech")
        let persistenceOperation = self.deviceStateStore.persistInterest("tech")
        XCTAssertFalse(persistenceOperation)
    }

    func testPersistInterestsThatWereNotSavedYet() {
        let interests = ["a", "b", "c", "d", "e"]
        _ = self.deviceStateStore.persistInterests(interests)
        let storedInterests = self.deviceStateStore.getInterests()
        XCTAssertNotNil(storedInterests!)
        XCTAssertTrue(interests.containsSameElements(as: storedInterests!))
    }

    func testRemoveInterestFromTheStorage() {
        let removeOperation = self.deviceStateStore.removeInterest(interest: "tech")
        XCTAssertFalse(removeOperation)
    }

    func testRemoveExistingInterestFromTheStorage() {
        _ = self.deviceStateStore.persistInterest("tech")
        let removeOperation = self.deviceStateStore.removeInterest(interest: "tech")
        XCTAssertTrue(removeOperation)
    }

    func testRemoveAllInterests() {
        _ = self.deviceStateStore.persistInterests(["a", "b", "c", "d", "e"])
        self.deviceStateStore.removeAllInterests()
        let interests = self.deviceStateStore.getInterests()
        XCTAssertEqual(interests!, [])
    }

    func testPersistInterestAndBatchSaveInterests() {
        let persistenceOperation = self.deviceStateStore.persistInterest("interest")
        XCTAssertTrue(persistenceOperation)
        let interests = ["a", "b", "c", "d", "e"]
        _ = self.deviceStateStore.persistInterests(interests)
        let storedInterests = self.deviceStateStore.getInterests()
        XCTAssertNotNil(storedInterests!)
        XCTAssert(storedInterests?.count == 5)
        XCTAssertTrue(interests.containsSameElements(as: storedInterests!))
    }

    func testBatchSaveInterestsAndPersistAnotherInterest() {
        let interests = ["a", "b", "c", "d", "e"]
        _ = self.deviceStateStore.persistInterests(interests)
        let persistenceOperation = self.deviceStateStore.persistInterest("interest")
        let storedInterests = self.deviceStateStore.getInterests()
        XCTAssertNotNil(storedInterests!)
        XCTAssertTrue(persistenceOperation)
        XCTAssert(storedInterests?.count == 6)
        XCTAssertTrue(storedInterests!.containsSameElements(as: ["a", "b", "c", "d", "e", "interest"]))
    }

    func testBatchSaveInterestsAndSaveExistingInterest() {
        let interests = ["a", "b", "c"]
        _ = self.deviceStateStore.persistInterests(interests)
        let persistenceOperation = self.deviceStateStore.persistInterest("a")
        XCTAssertFalse(persistenceOperation)
        let storedInterests = self.deviceStateStore.getInterests()
        XCTAssert(storedInterests?.count == 3)
        XCTAssertTrue(storedInterests!.containsSameElements(as: interests))
    }

    func testBatchSaveSameInterestsTwice() {
        let interests = ["a", "b", "c"]
        let persistenceOperation = self.deviceStateStore.persistInterests(interests)
        XCTAssertTrue(persistenceOperation)
        let persistSameInterestSetAgain = self.deviceStateStore.persistInterests(interests)
        XCTAssertFalse(persistSameInterestSetAgain)
    }

    func testPersistInterestWithALongName() {
        let interestWithALongName = "cs3pbizT,UjWwYXfguIm@y=l730QOOJvPfWV@W0_h2_IO8mkEzeS1JXwC@nHJDuZwbrgtsCVXAA3=9CIkQW69,.4d6Cs5Ny_gRALxAj3YlXEk674SGiqWgX:T74M6yQAqWfSGSJT.unKgg3J0ZqiQng__2V8ladmfVNw"
        let persistenceOperation = self.deviceStateStore.persistInterest(interestWithALongName)
        XCTAssertTrue(persistenceOperation)
        let storedInterests = self.deviceStateStore.getInterests()
        XCTAssertNotNil(storedInterests!)
        XCTAssertTrue(storedInterests?.count == 1)
        XCTAssertTrue(storedInterests!.containsSameElements(as: [interestWithALongName]))
    }

    func testInterestsHash() {
        self.deviceStateStore.persistServerConfirmedInterestsHash("749e2830366ba863f796cdf5e281662f")

        XCTAssertEqual(self.deviceStateStore.getServerConfirmedInterestsHash(), "749e2830366ba863f796cdf5e281662f")
    }

    func testNilInterestsHash() {
        XCTAssertEqual(self.deviceStateStore.getServerConfirmedInterestsHash(), "")
    }
}
