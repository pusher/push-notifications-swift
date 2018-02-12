import Foundation

struct Instance {
    static func persist(_ instanceId: String) throws {
        guard let savedInstanceId = Instance.getInstanceId() else {
            UserDefaults(suiteName: "PushNotifications")?.set(instanceId, forKey: "com.pusher.sdk.instanceId")
            return
        }

        if(instanceId != savedInstanceId) {
            let errorMessage = """
            This device has already been registered with Pusher.
            Push Notifications application with instance id: \(savedInstanceId).
            If you would like to register this device to \(instanceId) please reinstall the application.
            """

            throw PusherAlreadyRegisteredError.instanceId(errorMessage)
        }
    }

    static func getInstanceId() -> String? {
        return UserDefaults(suiteName: "PushNotifications")?.string(forKey: "com.pusher.sdk.instanceId")
    }
}
