import Foundation

enum PushNotificationsAPIError {
    case DeviceNotFound
    case BadRequest
    case BadJWT(reason: String)
    case GenericError(reason: String)

    func getErrorMessage() -> String {
        switch self {
        case .DeviceNotFound:
            return "Device Not Found"
        case .BadRequest:
            return "Bad Request"
        case .BadJWT(let reason):
            return "Bad JWT: \(reason)"
        case .GenericError(let reason):
            return "Error: \(reason)"
        }
    }
}
