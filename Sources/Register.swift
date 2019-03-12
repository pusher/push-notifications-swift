import Foundation

struct Register: Encodable {
    let token: String
    let bundleIdentifier: String
    let metadata: Metadata
}
