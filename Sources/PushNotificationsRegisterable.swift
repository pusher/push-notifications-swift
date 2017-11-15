import Foundation

protocol PushNotificationsRegisterable {
    typealias CompletionHandler = (String) -> ()
    func register(deviceToken: Data, completion: @escaping CompletionHandler)
}
