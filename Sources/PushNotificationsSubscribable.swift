import Foundation

protocol PushNotificationsSubscribable {
    func subscribe(completion: @escaping () -> Void)
    func setSubscriptions(interests: Array<String>, completion: @escaping () -> Void)

    func unsubscribe(completion: @escaping () -> Void)
    func unsubscribeAll(completion: @escaping () -> Void)
}
