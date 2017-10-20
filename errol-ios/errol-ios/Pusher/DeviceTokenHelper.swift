import Foundation

extension Data {
    func hexadecimalRepresentation() -> String {
        return map { String(format: "%02.2hhx", $0) }.joined() // https://stackoverflow.com/a/40031342
    }
}
