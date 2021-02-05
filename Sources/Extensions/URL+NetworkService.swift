import Foundation

extension URL {

    struct PushNotifications {

        // MARK: - Private methods

        private static let hostName = "pushnotifications.pusher.com"

        private static func devicesEndpoint(instanceId: String) -> String {
            return "https://\(instanceId).\(hostName)/device_api/v1/instances/\(instanceId)/devices/apns"
        }

        private static func deviceEndpoint(instanceId: String,
                                           deviceId: String) -> String {
            return "\(devicesEndpoint(instanceId: instanceId))/\(deviceId)"
        }

        private static func eventEndpoint(instanceId: String) -> String {
            return "https://\(instanceId).\(hostName)/reporting_api/v2/instances/\(instanceId)/events"
        }

        // MARK: - Endpoint URLs

        static func devices(instanceId: String) -> URL? {
            return URL(string: devicesEndpoint(instanceId: instanceId))
        }

        static func device(instanceId: String,
                           deviceId: String) -> URL? {
            return URL(string: deviceEndpoint(instanceId: instanceId, deviceId: deviceId))
        }

        static func interests(instanceId: String,
                              deviceId: String) -> URL? {
            return URL(string: "\(deviceEndpoint(instanceId: instanceId, deviceId: deviceId))/interests")
        }

        static func interest(instanceId: String,
                             deviceId: String,
                             interest: String) -> URL? {
            return URL(string: "\(deviceEndpoint(instanceId: instanceId, deviceId: deviceId))/interests/\(interest)")
        }

        static func events(instanceId: String) -> URL? {
            return URL(string: eventEndpoint(instanceId: instanceId))
        }

        static func metadata(instanceId: String,
                             deviceId: String) -> URL? {
            return URL(string: "\(deviceEndpoint(instanceId: instanceId, deviceId: deviceId))/metadata")
        }

        static func user(instanceId: String,
                         deviceId: String) -> URL? {
            return URL(string: "\(deviceEndpoint(instanceId: instanceId, deviceId: deviceId))/user")
        }
    }
}
