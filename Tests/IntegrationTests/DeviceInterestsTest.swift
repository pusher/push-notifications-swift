import XCTest
import Nimble
@testable import PushNotifications

class DeviceInterestsTest: XCTestCase {
    // Real production instance.
    let instanceId = "1b880590-6301-4bb5-b34f-45db1c5f5644"
    let validToken = "notadevicetoken-apns-DeviceInterestsTest".data(using: .utf8)!

    override func setUp() {
        if let deviceId = Device.getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    override func tearDown() {
        if let deviceId = Device.getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }

        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }
    }

    func testInterestNameValidation() {
        let pushNotifications = PushNotifications.shared
        XCTAssertThrowsError(try pushNotifications.addDeviceInterest(interest: "hello$*"))
        XCTAssertThrowsError(try pushNotifications.removeDeviceInterest(interest: "hello$*"))

        let invalidInterests = ["¢123", "#ssss#dds", "£", "hello|world"]
        let validInterests = ["a;b", "hello-world", "pusher.com", "@cucas", "apples,grapes,oranges==fruit"]
        let allInterests = invalidInterests + validInterests
        XCTAssertThrowsError(try PushNotifications.shared.setDeviceInterests(interests: allInterests)) { error in
            guard case MultipleInvalidInterestsError.invalidNames(let names) = error else {
                return XCTFail()
            }

            XCTAssertNotNil(names)
            XCTAssertEqual(names, invalidInterests)
        }

        try! invalidInterests.forEach { interest in
            XCTAssertThrowsError(try pushNotifications.addDeviceInterest(interest: interest))
            XCTAssertThrowsError(try pushNotifications.removeDeviceInterest(interest: interest))
        }

        try! validInterests.forEach { interest in
            XCTAssertNoThrow(try pushNotifications.addDeviceInterest(interest: interest))
            XCTAssertNoThrow(try pushNotifications.removeDeviceInterest(interest: interest))
        }
    }

    func testSubscribingAndUnsubscribingBeforeTheStartWorks() {
        let pushNotifications = PushNotifications.shared
        XCTAssertNoThrow(try pushNotifications.addDeviceInterest(interest: "panda"))
        var interests = pushNotifications.getDeviceInterests()
        XCTAssertNotNil(interests)
        XCTAssertEqual(interests, ["panda"])

        XCTAssertNoThrow(try pushNotifications.removeDeviceInterest(interest: "panda"))
        interests = pushNotifications.getDeviceInterests()
        XCTAssertEqual(interests, [])

        XCTAssertNoThrow(try pushNotifications.setDeviceInterests(interests: ["1", "2", "3"]))
        interests = pushNotifications.getDeviceInterests()
        XCTAssertTrue(interests!.containsSameElements(as: ["1", "2", "3"]))
    }

    func testInterestsShouldBeSynchronisedAfterStart() {
        let pushNotifications = PushNotifications.shared
        XCTAssertNoThrow(try pushNotifications.addDeviceInterest(interest: "panda"))

        pushNotifications.start(instanceId: instanceId)
        pushNotifications.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = Device.getDeviceId()!

        expect(TestAPIClientHelper().getDeviceInterests(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(equal(["panda"]), timeout: 10)
    }

    func testLocalInterestsSetShouldBeMergedAfterDeviceRegistration() {
        // Creating device and setting interests to simulate preexisting device with interests.
        let pushNotifications = PushNotifications()
        XCTAssertNoThrow(try pushNotifications.addDeviceInterest(interest: "panda"))
        XCTAssertNoThrow(try pushNotifications.addDeviceInterest(interest: "zebra"))

        pushNotifications.start(instanceId: instanceId)
        pushNotifications.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId = Device.getDeviceId()!

        expect(TestAPIClientHelper().getDeviceInterests(instanceId: self.instanceId, deviceId: deviceId))
            .toEventually(equal(["panda", "zebra"]), timeout: 10)

        // Clearing local storage to pretend that SDK didn't start.
        UserDefaults(suiteName: Constants.UserDefaults.suiteName).map { userDefaults in
            Array(userDefaults.dictionaryRepresentation().keys).forEach(userDefaults.removeObject)
        }

        // Creating new instance to pretend a fresh state
        let pushNotifications2 = PushNotifications()
        XCTAssertNoThrow(try pushNotifications2.removeDeviceInterest(interest: "panda"))
        XCTAssertNoThrow(try pushNotifications2.addDeviceInterest(interest: "lion"))

        class StubInterestsChanged: InterestsChangedDelegate {
            let completion: ([String]) -> ()
            init(completion: @escaping ([String]) -> ()) {
                self.completion = completion
            }

            func interestsSetOnDeviceDidChange(interests: [String]) {
                completion(interests)
            }
        }
        let exp = expectation(description: "Interests changed called with ['zebra', 'lion']")
        let stubInterestsChanged = StubInterestsChanged(completion: { interests in
            XCTAssertTrue(interests.containsSameElements(as: ["zebra", "lion"]))
            exp.fulfill()
        })
        pushNotifications2.delegate = stubInterestsChanged

        pushNotifications2.start(instanceId: instanceId)
        pushNotifications2.registerDeviceToken(validToken)

        expect(Device.getDeviceId()).toEventuallyNot(beNil(), timeout: 10)
        let deviceId2 = Device.getDeviceId()!
        XCTAssertEqual(deviceId, deviceId2)

        expect(TestAPIClientHelper().getDeviceInterests(instanceId: self.instanceId, deviceId: deviceId2))
            .toEventually(contain("zebra", "lion"), timeout: 10)
        waitForExpectations(timeout: 1)
    }

    func testInterestsSetDidChangeAndCallbackIsCalled() {
        let pushNotifications = PushNotifications()

        class StubInterestsChanged: InterestsChangedDelegate {
            let completion: ([String]) -> ()
            init(completion: @escaping ([String]) -> ()) {
                self.completion = completion
            }

            func interestsSetOnDeviceDidChange(interests: [String]) {
                completion(interests)
            }
        }

        var exp = expectation(description: "Interests changed called with ['a']")
        var stubInterestsChanged = StubInterestsChanged(completion: { interests in
            XCTAssertEqual(interests, ["a"])
            exp.fulfill()
        })
        pushNotifications.delegate = stubInterestsChanged
        XCTAssertNoThrow(try pushNotifications.addDeviceInterest(interest: "a"))

        waitForExpectations(timeout: 1)

        exp = expectation(description: "Interests changed not called")
        exp.isInverted = true
        stubInterestsChanged = StubInterestsChanged(completion: { interests in
            exp.fulfill()
        })
        pushNotifications.delegate = stubInterestsChanged
        XCTAssertNoThrow(try pushNotifications.addDeviceInterest(interest: "a"))

        exp = expectation(description: "Interests changed called with []")
        stubInterestsChanged = StubInterestsChanged(completion: { interests in
            XCTAssertEqual(interests, [])
            exp.fulfill()
        })
        pushNotifications.delegate = stubInterestsChanged
        XCTAssertNoThrow(try pushNotifications.removeDeviceInterest(interest: "a"))

        waitForExpectations(timeout: 1)

        exp = expectation(description: "Interests changed not called")
        exp.isInverted = true
        stubInterestsChanged = StubInterestsChanged(completion: { interests in
            exp.fulfill()
        })
        pushNotifications.delegate = stubInterestsChanged
        XCTAssertNoThrow(try pushNotifications.removeDeviceInterest(interest: "a"))

        waitForExpectations(timeout: 1)

        exp = expectation(description: "Interests changed called with ['a', 'b', 'c']")
        stubInterestsChanged = StubInterestsChanged(completion: { interests in
            XCTAssertTrue(interests.containsSameElements(as: ["a", "b", "c"]))
            exp.fulfill()
        })
        pushNotifications.delegate = stubInterestsChanged
        XCTAssertNoThrow(try pushNotifications.setDeviceInterests(interests: ["a", "b", "c"]))

        waitForExpectations(timeout: 1)

        exp = expectation(description: "Interests changed not called")
        exp.isInverted = true
        stubInterestsChanged = StubInterestsChanged(completion: { interests in
            exp.fulfill()
        })
        pushNotifications.delegate = stubInterestsChanged
        XCTAssertNoThrow(try pushNotifications.setDeviceInterests(interests: ["a", "b", "c"]))

        waitForExpectations(timeout: 1)
    }
}
