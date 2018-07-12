import Foundation
import CommonCrypto

extension Array where Element == String {
    func calculateMD5Hash() -> String? {
        let sortedArray = self.sorted()
        let elementsJoined = String(sortedArray.joined(separator: ","))

        guard let messageData = elementsJoined.data(using: .utf8) else { return nil }
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))

        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }

        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
