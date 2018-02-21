import Foundation

struct Metadata: Encodable {
    let sdkVersion: String
    let iosVersion: String?
    let macosVersion: String?
}

extension Metadata: PropertyListReadable {
    func propertyListRepresentation() -> Dictionary<String, Any> {
        return ["sdkVersion": self.sdkVersion, "iosVersion": self.iosVersion ?? "", "macosVersion": self.macosVersion ?? ""]
    }

    init(propertyListRepresentation: Dictionary<String, Any>) {
        self.sdkVersion = propertyListRepresentation["sdkVersion"] as! String
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
        let userDefaults = UserDefaults(suiteName: "PushNotifications")
        userDefaults?.set(self.propertyListRepresentation(), forKey: "com.pusher.sdk.metadata")
    }

    static func load() -> Dictionary<String, Any>? {
        let userDefaults = UserDefaults(suiteName: "PushNotifications")
        let metadata = userDefaults?.object(forKey: "com.pusher.sdk.metadata") as? Dictionary<String, String>

        return metadata
    }
}
