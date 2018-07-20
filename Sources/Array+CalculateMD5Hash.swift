import Foundation

extension Array where Element == String {
    func calculateMD5Hash() -> String {
        let sortedArray = self.sorted()
        let elementsJoined = String(sortedArray.joined(separator: ","))

        return MD5(elementsJoined)
    }
}
