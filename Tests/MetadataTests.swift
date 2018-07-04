import XCTest
@testable import PushNotifications

class MetadataTests: XCTestCase {
    var metadata: Metadata!

    override func setUp() {
        #if os(iOS)
        self.metadata = Metadata(sdkVersion: "0.9.2", iosVersion: "10.2", macosVersion: nil)
        #elseif os(OSX)
        self.metadata = Metadata(sdkVersion: "0.9.2", iosVersion: nil, macosVersion: "10.0")
        #endif
        super.setUp()
    }

    override func tearDown() {
        self.metadata = nil
        super.tearDown()
    }

    #if os(iOS)
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
    #elseif os(OSX)
    func testMetadataModel() {
        XCTAssertNotNil(self.metadata)
        XCTAssertNotNil(self.metadata.sdkVersion)
        XCTAssertNil(self.metadata.iosVersion)
        XCTAssertNotNil(self.metadata.macosVersion)

        XCTAssert(self.metadata.sdkVersion == "0.9.2")
        XCTAssert(self.metadata.iosVersion == nil)
        XCTAssert(self.metadata.macosVersion == "10.0")
    }

    func testPropertyListRepresentation() {
        let propertyListRepresentation = self.metadata.propertyListRepresentation()
        XCTAssertNotNil(propertyListRepresentation)
        XCTAssertNotNil(propertyListRepresentation["sdkVersion"])
        XCTAssertNotNil(propertyListRepresentation["iosVersion"])
        XCTAssertNotNil(propertyListRepresentation["macosVersion"])

        XCTAssert(propertyListRepresentation["sdkVersion"] as! String == "0.9.2")
        XCTAssert(propertyListRepresentation["iosVersion"] as? String == "")
        XCTAssert(propertyListRepresentation["macosVersion"] as? String == "10.0")
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
        XCTAssert(metadata.iosVersion == "")
        XCTAssert(metadata.macosVersion == "10.0")
    }
    #endif

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
        XCTAssert(metadata.sdkVersion == "0.10.11")
    }
}
