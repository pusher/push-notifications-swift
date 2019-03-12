import Foundation

typealias CompletionHandler<T> = (_ result: T) -> Void

protocol PushNotificationsNetworkable {
    func register(deviceToken: String, metadata: Metadata, retryStrategy: RetryStrategy) -> Result<Device, PushNotificationsAPIError>

    func subscribe(deviceId: String, interest: String, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func setSubscriptions(deviceId: String, interests: [String], retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func unsubscribe(deviceId: String, interest: String, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func track(deviceId: String, eventType: ReportEventType, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func syncMetadata(deviceId: String, metadata: Metadata, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func setUserId(deviceId: String, token: String, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func deleteDevice(deviceId: String, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func getDevice(deviceId: String, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>
}
