import Foundation

struct Device: Decodable {
    var id: String
    var initialInterestSet: Set<String>?
}
