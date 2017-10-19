import Foundation
import UserNotifications

struct Pusher {
    let instanceId: String

    public func register() {
        self.registerForPushNotifications()
    }

    public func registerDeviceToken(_ deviceToken: Data) {
        let session = URLSession.shared
        let url = URL(string: "https://errol-staging.herokuapp.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        let networkService = NetworkService(url: url, session: session)

        networkService.register(deviceToken: deviceToken)
    }

    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
        }
    }
}
