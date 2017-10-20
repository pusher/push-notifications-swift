import UIKit
import Foundation
import UserNotifications

final class Pusher {
    let instanceId: String
    private var deviceId: String?
    private let session = URLSession.shared
    private let baseURL = "https://errol-staging.herokuapp.com/device_api/v1/instances"

    public init(instanceId: String) {
        self.instanceId = instanceId
    }

    public func register(application: UIApplication) {
        self.registerForPushNotifications(application: application)
    }

    public func registerDeviceToken(_ deviceToken: Data) {
        guard let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/ppns") else { return }
        let networkService: PusherRegisterable & PusherSubscribable = NetworkService(url: url, session: session)

        networkService.register(deviceToken: deviceToken) { [weak self] (deviceId) in
            guard let strongSelf = self else { return }
            strongSelf.deviceId = deviceId
        }
    }

    public func subscribe(interest: String) {
        guard
            let deviceId = self.deviceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/ppns/\(deviceId)/interests/\(interest)")
        else { return }

        let networkService: PusherRegisterable & PusherSubscribable = NetworkService(url: url, session: session)

        networkService.subscribe()
    }

    public func unsubscribe(interest: String) {
        guard
            let deviceId = self.deviceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/ppns/\(deviceId)/interests/\(interest)")
        else { return }

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
