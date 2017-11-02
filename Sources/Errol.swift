import UIKit
import Foundation
import UserNotifications

public final class Errol {
    private var deviceId: String?
    private var instanceId: String?
    private let session = URLSession.shared
    private let baseURL = "https://errol-staging.herokuapp.com/device_api/v1/instances"


    //! Returns a shared singleton Errol object.
    public static let shared = Errol()

    private init() {}

    /**
     Register with Errol service.

     - Parameter instanceId: Errol instance id.
     - Parameter application: Your singleton app object.

     - Precondition: `instanceId` should not be nil.
     - Precondition: `application` should not be nil.
     */
    public func register(instanceId: String, application: UIApplication = UIApplication.shared) {
        self.instanceId = instanceId
        self.registerForPushNotifications(application: application)
    }

    /**
     Register device token with Errol service.

     - Parameter deviceToken: A token that identifies the device to APNs.
     - Parameter completion: The block to execute when the register device token operation is complete.

     - Precondition: `deviceToken` should not be nil.
     */
    public func registerDeviceToken(_ deviceToken: Data, completion: @escaping () -> Void = {}) {
        guard
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns")
        else { return }

        let networkService: ErrolRegisterable & ErrolSubscribable = NetworkService(url: url, session: session)

        networkService.register(deviceToken: deviceToken) { [weak self] (deviceId) in
            guard let strongSelf = self else { return }
            strongSelf.deviceId = deviceId
            completion()
        }
    }

    /**
     Subscribe to an interest.

     - Parameter interest: Interest that you want to subscribe to.
     - Parameter completion: The block to execute when subscription to the interest is complete.

     - Precondition: `interest` should not be nil.
     */
    public func subscribe(interest: String, completion: @escaping () -> Void = {}) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")
        else { return }

        let networkService: ErrolRegisterable & ErrolSubscribable = NetworkService(url: url, session: session)

        networkService.subscribe {
            completion()
        }
    }

    /**
     Set subscriptions.

     - Parameter interests: Interests that you want to subscribe to.
     - Parameter completion: The block to execute when subscription to interests is complete.

     - Precondition: `interests` should not be nil.
     */
    public func setSubscriptions(interests: Array<String>, completion: @escaping () -> Void = {}) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests")
        else { return }

        let networkService: ErrolRegisterable & ErrolSubscribable = NetworkService(url: url, session: session)

        networkService.setSubscriptions(interests: interests) {
            completion()
        }
    }

    /**
     Unsubscribe from an interest.

     - Parameter interest: Interest that you want to unsubscribe to.
     - Parameter completion: The block to execute when subscription to the interest is successfully cancelled.

     - Precondition: `interest` should not be nil.
     */
    public func unsubscribe(interest: String, completion: @escaping () -> Void = {}) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests/\(interest)")
        else { return }

        let networkService: ErrolRegisterable & ErrolSubscribable = NetworkService(url: url, session: session)

        networkService.unsubscribe {
            completion()
        }
    }

    /**
     Unsubscribe from all interests.

     - Parameter completion: The block to execute when all subscriptions to the interests are successfully cancelled.
     */
    public func unsubscribeAll(completion: @escaping () -> Void = {}) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests")
        else { return }

        let networkService: ErrolRegisterable & ErrolSubscribable = NetworkService(url: url, session: session)

        networkService.unsubscribeAll {
            completion()
        }
    }

    /**
     Get a list of all interests.

     - Parameter completion: The block to execute when list of interests is successfully retrieved.
     */
    public func getInterests(completion: @escaping (Array<String>) -> Void) {
        guard
            let deviceId = self.deviceId,
            let instanceId = self.instanceId,
            let url = URL(string: "\(self.baseURL)/\(instanceId)/devices/apns/\(deviceId)/interests")
        else { return }

        let networkService: ErrolRegisterable & ErrolSubscribable = NetworkService(url: url, session: session)

        networkService.getInterests { (interestSet) in
            completion(interestSet)
        }
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
