import Foundation

struct DeviceTokenHelper {
    func convertToString(_ deviceToken: Data) -> String {
        return deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    }
}
