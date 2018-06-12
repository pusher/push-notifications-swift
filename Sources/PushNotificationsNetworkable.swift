import Foundation

typealias CompletionHandler<T> = (_ result: T?, _ wasSuccessful: Bool) -> Void

protocol PushNotificationsNetworkable {
    func register(deviceToken: Data, instanceId: String, completion: @escaping CompletionHandler<Device>)

    func subscribe(completion: @escaping CompletionHandler<String>)
    func setSubscriptions(interests: Array<String>, completion: @escaping CompletionHandler<String>)

    func unsubscribe(completion: @escaping CompletionHandler<String>)
    func unsubscribeAll(completion: @escaping CompletionHandler<String>)

    func track(eventType: ReportEventType, completion: @escaping CompletionHandler<String>)

    func syncMetadata(completion: @escaping CompletionHandler<String>)
}
