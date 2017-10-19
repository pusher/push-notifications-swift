import UIKit
import Foundation
import UserNotifications

struct Pusher {
    let instanceId: String

    public func register(application: UIApplication) {
        self.registerForPushNotifications(application: application)
    }

    public func registerDeviceToken(_ deviceToken: Data) {
        let session = URLSession.shared
        let url = URL(string: "https://errol-staging.herokuapp.com/device_api/v1/instances/\(instanceId)/devices/apns")!
        let networkService = NetworkService(url: url, session: session)

        networkService.register(deviceToken: deviceToken)
    }

    private func registerForPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if (granted) {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
}
