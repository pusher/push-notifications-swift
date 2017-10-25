import Foundation

struct Reason: Decodable {
    var description: String

    private enum CodingKeys : String, CodingKey {
        case description = "desc"
    }
}
