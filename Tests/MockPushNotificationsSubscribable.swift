import Foundation

struct MockPushNotificationsSubscribable: PushNotificationsSubscribable {
    func subscribe(completion: @escaping () -> Void) {
        completion()
    }

    func setSubscriptions(interests: Array<String>, completion: @escaping () -> Void) {
        completion()
    }

    func unsubscribe(completion: @escaping () -> Void) {
        completion()
    }

    func unsubscribeAll(completion: @escaping () -> Void) {
        completion()
    }
}
