import Foundation

@objc public class AuthData: NSObject {
    public let headers: [String: String]
    public let urlParams: [String: String]

    public init(headers: [String: String], urlParams: [String: String]) {
        self.headers = headers
        self.urlParams = urlParams
    }
}
