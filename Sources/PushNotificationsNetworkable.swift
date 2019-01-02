import Foundation

typealias CompletionHandler<T> = (_ result: T) -> Void

protocol PushNotificationsNetworkable {
    func register(url: URL, deviceToken: Data, instanceId: String, completion: @escaping CompletionHandler<Result<Device, Error>>)

    func subscribe(url: URL, completion: @escaping CompletionHandler<Result<Void, Error>>)
    func setSubscriptions(url: URL, interests: [String], completion: @escaping CompletionHandler<Result<Void, Error>>)

    func unsubscribe(url: URL, completion: @escaping CompletionHandler<Result<Void, Error>>)

    func track(url: URL, eventType: ReportEventType, completion: @escaping CompletionHandler<Result<Void, Error>>)

    func syncMetadata(url: URL, completion: @escaping CompletionHandler<Result<Void, Error>>)

    func setUserId(url: URL, token: String, completion: @escaping CompletionHandler<Result<Void, Error>>)
    func deleteDevice(url: URL, completion: @escaping CompletionHandler<Result<Void, Error>>)

    func getDevice(url: URL, completion: @escaping CompletionHandler<Result<Void, Error>>)
}
