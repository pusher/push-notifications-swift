import Foundation

typealias CompletionHandler<T> = (_ result: T) -> Void

protocol PushNotificationsNetworkable {
    func register(instanceId: String, deviceToken: String, metadata: Metadata, retryStrategy: RetryStrategy) -> Result<Device, PushNotificationsAPIError>

    func subscribe(instanceId: String, deviceId: String, interest: String, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func setSubscriptions(instanceId: String, deviceId: String, interests: [String], retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func unsubscribe(instanceId: String, deviceId: String, interest: String, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func track(instanceId: String, deviceId: String, eventType: ReportEventType, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func syncMetadata(instanceId: String, deviceId: String, metadata: Metadata, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func setUserId(instanceId: String, deviceId: String, token: String, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func deleteDevice(instanceId: String, deviceId: String, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>

    func getDevice(instanceId: String, deviceId: String, retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError>
}
