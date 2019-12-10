import Foundation

struct PersistenceConstants {
    struct UserDefaults {
        static func suiteName(instanceId: String?) -> String {
            if instanceId == nil {
                return "PushNotifications"
            } else {
                return "PushNotifications.\(instanceId!)"
            }
        }
        
        static let globalSuiteName = "PushNotificationsInstances"
        static let metadataSDKVersion = "com.pusher.sdk.metadata.sdkVersion"
        static let metadataiOSVersion = "com.pusher.sdk.metadata.iosVersion"
        static let metadataMacOSVersion = "com.pusher.sdk.metadata.macosVersion"
        static let deviceId = "com.pusher.sdk.deviceId"
        static let deviceAPNsToken = "com.pusher.sdk.deviceAPNsToken"
        static let instanceId = "com.pusher.sdk.instanceId"
    }

    struct PersistenceService {
        static let instanceIdsPrefix = "com.pusher.sdk.instanceIds"
        static let prefix = "com.pusher.sdk.interests"
        static let userId = "com.pusher.sdk.user.id"
        static let hashKey = "interestsHash"
        static let globalScopeId = "com.pusher.sdk"
    }

    struct PushNotificationsInstancePersistence {
        static let userId = "com.pusher.sdk.pni.user.id.called.with"
        static let startJob = "com.pusher.sdk.pni.start.job.enqueued"
    }
}
