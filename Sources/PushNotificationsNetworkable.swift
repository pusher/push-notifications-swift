import Foundation

typealias CompletionHandler<T> = (_ result: T) -> Void

protocol PushNotificationsNetworkable {
    func register(url: URL, deviceToken: Data, instanceId: String) -> Result<Device, Error>

    func subscribe(url: URL) -> Result<Void, Error>
    func setSubscriptions(url: URL, interests: [String]) -> Result<Void, Error>

    func unsubscribe(url: URL) -> Result<Void, Error>

    func track(url: URL, eventType: ReportEventType) -> Result<Void, Error>

    func syncMetadata(url: URL) -> Result<Void, Error>

    func setUserId(url: URL, token: String) -> Result<Void, Error>
    func deleteDevice(url: URL) -> Result<Void, Error>

    func getDevice(url: URL) -> Result<Void, Error>
}
