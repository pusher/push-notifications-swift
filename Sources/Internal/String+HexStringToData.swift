import Foundation

extension String {
    func hexStringToData() -> Data? {
        let len = self.count / 2
        var data = Data(capacity: len)
        for index in 0..<len {
            let startOffset = self.index(self.startIndex, offsetBy: index*2)
            let endOffset = self.index(startOffset, offsetBy: 2)
            let bytes = self[startOffset..<endOffset]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        return data
    }
}
