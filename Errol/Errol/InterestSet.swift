import Foundation

struct InterestSet: Decodable {
    var interests: Array<String>
    var metadata: Dictionary<String, String>

    private enum CodingKeys : String, CodingKey {
        case interests = "interests"
        case metadata = "responseMetadata"
    }
}
