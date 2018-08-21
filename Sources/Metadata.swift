import Foundation

struct Metadata: Encodable {
    let sdkVersion: String?
    let iosVersion: String?
    let macosVersion: String?
}

extension Metadata: PropertyListReadable {
    func propertyListRepresentation() -> [String: Any] {
        return ["sdkVersion": self.sdkVersion ?? "", "iosVersion": self.iosVersion ?? "", "macosVersion": self.macosVersion ?? ""]
    }

    init(propertyListRepresentation: [String: Any]) {
        self.sdkVersion = propertyListRepresentation["sdkVersion"]  as? String
        self.iosVersion = propertyListRepresentation["iosVersion"] as? String
        self.macosVersion = propertyListRepresentation["macosVersion"] as? String
    }

    func hasChanged() -> Bool {
        return self.sdkVersion != SDK.version
    }

    static func update() -> Metadata {
        let sdkVersion = SDK.version
        let systemVersion = SystemVersion.version

        #if os(iOS)
            let metadata = Metadata(sdkVersion: sdkVersion, iosVersion: systemVersion, macosVersion: nil)
        #elseif os(OSX)
            let metadata = Metadata(sdkVersion: sdkVersion, iosVersion: nil, macosVersion: systemVersion)
        #endif
        metadata.save()

        return metadata
    }

    func save() {
        let userDefaults = UserDefaults(suiteName: Constants.UserDefaults.suiteName)
        userDefaults?.set(self.propertyListRepresentation(), forKey: Constants.UserDefaults.metadata)
    }

    static func load() -> [String: Any]? {
        let userDefaults = UserDefaults(suiteName: Constants.UserDefaults.suiteName)
        let metadata = userDefaults?.object(forKey: Constants.UserDefaults.metadata) as? [String: String]

        return metadata
    }
}
