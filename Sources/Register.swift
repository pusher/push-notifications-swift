import Foundation

struct Register: Codable {
    let token: String
    let bundleIdentifier: String
    let metadata: Metadata
}
