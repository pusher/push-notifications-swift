import Foundation

struct Constants {
    struct UserDefaults {
        static let suiteName = "PushNotifications"
        static let metadataSDKVersion = "com.pusher.sdk.metadata.sdkVersion"
        static let metadataiOSVersion = "com.pusher.sdk.metadata.iosVersion"
        static let metadataMacOSVersion = "com.pusher.sdk.metadata.macosVersion"
        static let deviceId = "com.pusher.sdk.deviceId"
        static let deviceAPNsToken = "com.pusher.sdk.deviceAPNsToken"
        static let instanceId = "com.pusher.sdk.instanceId"
    }

    struct PersistanceService {
        static let prefix = "com.pusher.sdk.interests"
        static let userId = "com.pusher.sdk.user.id"
        static let hashKey = "interestsHash"
    }

    struct DispatchQueue {
        static let preIISOperationQueue = "com.pusher.pushnotifications.pre.iis.operation.queue"
        static let persistenceStorageOperationQueue = "com.pusher.pushnotifications.persistence.storage.operation.queue"
    }

    struct ReportEventType {
        static let open = "Open"
        static let delivery = "Delivery"
    }
}
