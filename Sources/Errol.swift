import UIKit
import Foundation
import UserNotifications

public final class Errol {
    private var deviceId: String?
    private var instanceId: String?
    private let session = URLSession.shared
    private let baseURL = "https://errol-staging.herokuapp.com/device_api/v1/instances"

    public static let shared = Errol()

    private init() {}

    public func register(instanceId: String, application: UIApplication) {
        self.instanceId = instanceId
        self.registerForPushNotifications(application: application)
    }

    public func registerDeviceToken(_ deviceToken: Data) {
        guard
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/ppns")
        else { return }

        let networkService: ErrolRegisterable & ErrolSubscribable = NetworkService(url: url, session: session)

        networkService.register(deviceToken: deviceToken) { [weak self] (deviceId) in
            guard let strongSelf = self else { return }
            strongSelf.deviceId = deviceId
        }
    }

    public func subscribe(interest: String) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/ppns/\(deviceId)/interests/\(interest)")
        else { return }

        let networkService: ErrolRegisterable & ErrolSubscribable = NetworkService(url: url, session: session)

        networkService.subscribe()
    }

    public func unsubscribe(interest: String) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/ppns/\(deviceId)/interests/\(interest)")
        else { return }

        let networkService: ErrolRegisterable & ErrolSubscribable = NetworkService(url: url, session: session)

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
