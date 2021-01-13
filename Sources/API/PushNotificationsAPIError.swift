import Foundation

enum PushNotificationsAPIError {
    case deviceNotFound
    case badRequest(reason: String)
    case badJWT(reason: String)
    case genericError(reason: String)
    case badDeviceToken(reason: String)

    func getErrorMessage() -> String {
        switch self {
        case .deviceNotFound:
            return "Device Not Found"
        case .badRequest(let reason):
            return "Bad Request: \(reason)"
        case .badJWT(let reason):
            return "Bad JWT: \(reason)"
        case .genericError(let reason):
            return "Error: \(reason)"
        case .badDeviceToken(let reason):
            return "Bad Device Token: \(reason)"
        }
    }
}
