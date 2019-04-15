import Foundation

enum PushNotificationsAPIError {
    case DeviceNotFound
    case BadRequest(reason: String)
    case BadJWT(reason: String)
    case GenericError(reason: String)
    case BadDeviceToken(reason: String)

    func getErrorMessage() -> String {
        switch self {
        case .DeviceNotFound:
            return "Device Not Found"
        case .BadRequest(let reason):
            return "Bad Request: \(reason)"
        case .BadJWT(let reason):
            return "Bad JWT: \(reason)"
        case .GenericError(let reason):
            return "Error: \(reason)"
        case .BadDeviceToken(let reason):
            return "Bad Device Token: \(reason)"
        }
    }
}
