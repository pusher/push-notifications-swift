import Foundation

typealias CompletionHandler<T> = (_ result: T) -> Void

protocol PushNotificationsNetworkable {
    func register(deviceToken: String, metadata: Metadata) -> Result<Device, Error>

    func subscribe(deviceId: String, interest: String) -> Result<Void, Error>

    func setSubscriptions(deviceId: String, interests: [String]) -> Result<Void, Error>

    func unsubscribe(deviceId: String, interest: String) -> Result<Void, Error>

    func track(deviceId: String, eventType: ReportEventType) -> Result<Void, Error>

    func syncMetadata(deviceId: String, metadata: Metadata) -> Result<Void, Error>

    func setUserId(deviceId: String, token: String) -> Result<Void, Error>

    func deleteDevice(deviceId: String) -> Result<Void, Error>

    func getDevice(deviceId: String) -> Result<Void, Error>
}
