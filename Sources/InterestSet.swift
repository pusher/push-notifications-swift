import Foundation

struct InterestSet: Decodable {
    var interests: Array<String>
    var responseMetadata: Dictionary<String, String>

    func nextCursor() -> String? {
        guard let nextCursor = self.responseMetadata["nextCursor"] else { return nil }

        return nextCursor
    }
}
