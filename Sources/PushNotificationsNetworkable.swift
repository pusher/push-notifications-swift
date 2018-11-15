import Foundation

typealias CompletionHandler<T> = (_ result: T?) -> Void

protocol PushNotificationsNetworkable {
    func register(url: URL, deviceToken: Data, instanceId: String, completion: @escaping CompletionHandler<Device>)

    func subscribe(url: URL, completion: @escaping CompletionHandler<String>)
    func setSubscriptions(url: URL, interests: [String], completion: @escaping CompletionHandler<String>)

    func unsubscribe(url: URL, completion: @escaping CompletionHandler<String>)

    func track(url: URL, eventType: ReportEventType, completion: @escaping CompletionHandler<String>)

    func syncMetadata(url: URL, completion: @escaping CompletionHandler<String>)

    func setUserId(url: URL, token: String, completion: @escaping CompletionHandler<String>)
    func deleteDevice(url: URL, completion: @escaping CompletionHandler<String>)
}
