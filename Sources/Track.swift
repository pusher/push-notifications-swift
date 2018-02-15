import Foundation

struct Track: Encodable {
    let publishId: String
    let timestampSecs: Double
    let eventType: String
    let deviceId: String
}
