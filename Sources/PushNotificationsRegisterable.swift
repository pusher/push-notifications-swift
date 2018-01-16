import Foundation

protocol PushNotificationsRegisterable {
    typealias CompletionHandler = (String) -> Void
    func register(deviceToken: Data, completion: @escaping CompletionHandler)
}
