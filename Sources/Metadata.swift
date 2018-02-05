import Foundation

struct Metadata: Encodable {
    let sdkVersion: String
    let iosVersion: String?
    let macosVersion: String?
}
