import Foundation

struct Metadata: Encodable {
    let sdkVersion: String
    let iosVersion: String?
    let macosVersion: String?
}

extension Metadata: PropertyListReadable {
    func propertyListRepresentation() -> Dictionary<String, Any> {
        let representation = ["sdkVersion": self.sdkVersion, "iosVersion": self.iosVersion ?? "", "macosVersion": self.macosVersion ?? ""]

        return representation
    }

    init(propertyListRepresentation: Dictionary<String, Any>) {
        self.sdkVersion = propertyListRepresentation["sdkVersion"] as! String
        self.iosVersion = propertyListRepresentation["iosVersion"] as? String
        self.macosVersion = propertyListRepresentation["macosVersion"] as? String
    }

    func save() {
        let userDefaults = UserDefaults(suiteName: "PushNotifications")
        userDefaults?.set(self.propertyListRepresentation(), forKey: "com.pusher.sdk.metadata")
    }

    static func load() -> Dictionary<String, Any> {
        let userDefaults = UserDefaults(suiteName: "PushNotifications")
        let metadata = userDefaults?.object(forKey: "com.pusher.sdk.metadata") as! Dictionary<String, String>

        return metadata
    }
}
