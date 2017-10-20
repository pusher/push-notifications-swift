import UIKit
import Foundation
import UserNotifications

struct Pusher {
    let instanceId: String
    private let session = URLSession.shared
    private let baseURL = "https://errol-staging.herokuapp.com/device_api/v1/instances"

    public func register(application: UIApplication) {
        self.registerForPushNotifications(application: application)
    }

    public func registerDeviceToken(_ deviceToken: Data) {
        guard let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/ppns") else { return }
        let networkService: PusherRegisterable & PusherSubscribable = NetworkService(url: url, session: session)

        networkService.register(deviceToken: deviceToken)
    }

    public func subscribe(interest: String) {
        guard let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/ppns/ppns-876eeb5d-0dc8-4d74-9f59-b65412b2c742/interests/\(interest)") else { return }
        let networkService: PusherRegisterable & PusherSubscribable = NetworkService(url: url, session: session)

        networkService.subscribe()
    }

    public func unsubscribe(interest: String) {
        guard let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/ppns/ppns-876eeb5d-0dc8-4d74-9f59-b65412b2c742/interests/\(interest)") else { return }
        let networkService: PusherRegisterable & PusherSubscribable = NetworkService(url: url, session: session)

        networkService.unsubscribe()
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
