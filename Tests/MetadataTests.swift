import XCTest
@testable import PushNotifications

class MetadataTests: XCTestCase {
    var metadata: Metadata!

    override func setUp() {
        self.metadata = Metadata(sdkVersion: "0.9.2", iosVersion: "10.2", macosVersion: nil)
        super.setUp()
    }

    override func tearDown() {
        self.metadata = nil
        super.tearDown()
    }

    func testMetadataModel() {
        XCTAssertNotNil(self.metadata)
        XCTAssertNotNil(self.metadata.sdkVersion)
        XCTAssertNotNil(self.metadata.iosVersion)
        XCTAssertNil(self.metadata.macosVersion)

        XCTAssert(self.metadata.sdkVersion == "0.9.2")
        XCTAssert(self.metadata.iosVersion == "10.2")
        XCTAssert(self.metadata.macosVersion == nil)
    }

    func testPropertyListRepresentation() {
        let propertyListRepresentation = self.metadata.propertyListRepresentation()
        XCTAssertNotNil(propertyListRepresentation)
        XCTAssertNotNil(propertyListRepresentation["sdkVersion"])
        XCTAssertNotNil(propertyListRepresentation["iosVersion"])
        XCTAssertNotNil(propertyListRepresentation["macosVersion"])

        XCTAssert(propertyListRepresentation["sdkVersion"] as! String == "0.9.2")
        XCTAssert(propertyListRepresentation["iosVersion"] as? String == "10.2")
        XCTAssert(propertyListRepresentation["macosVersion"] as? String == "")
    }

    func testSaveAndLoadFromUserDefaults() {
        self.metadata.save()
        guard let metadataDictionary = Metadata.load() else {
            XCTFail()
            return
        }
        let metadata = Metadata(propertyListRepresentation: metadataDictionary)
        XCTAssertNotNil(metadata.sdkVersion)
        XCTAssertNotNil(metadata.iosVersion)
        XCTAssertNotNil(metadata.macosVersion)
        XCTAssert(metadata.sdkVersion == "0.9.2")
        XCTAssert(metadata.iosVersion == "10.2")
        XCTAssert(metadata.macosVersion == "")
    }

    func testMetadataIsOutdated() {
        XCTAssertTrue(self.metadata.hasChanged())
    }

    func testMetadataUpdate() {
        let updatedMetadata = Metadata.update()
        XCTAssertNotNil(updatedMetadata)
        XCTAssertFalse(updatedMetadata.hasChanged())

        guard let metadataDictionary = Metadata.load() else {
            XCTFail()
            return
        }
        let metadata = Metadata(propertyListRepresentation: metadataDictionary)
        XCTAssertNotNil(metadata.sdkVersion)
        XCTAssertNotNil(metadata.iosVersion)
        XCTAssertNotNil(metadata.macosVersion)
        XCTAssert(metadata.sdkVersion == "0.10.3")
    }
}
