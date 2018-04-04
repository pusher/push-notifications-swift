import Foundation

typealias CompletionHandler = (_ result: String?, _ wasSuccessful: Bool) -> Void

protocol PushNotificationsNetworkable {
    func register(deviceToken: Data, instanceId: String, completion: @escaping CompletionHandler)

    func subscribe(completion: @escaping CompletionHandler)
    func setSubscriptions(interests: Array<String>, completion: @escaping CompletionHandler)

    func unsubscribe(completion: @escaping CompletionHandler)
    func unsubscribeAll(completion: @escaping CompletionHandler)

    func track(eventType: ReportEventType, completion: @escaping CompletionHandler)

    func syncMetadata(completion: @escaping CompletionHandler)
}
