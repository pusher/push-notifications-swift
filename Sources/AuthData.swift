import Foundation

@objc public class AuthData: NSObject {
    public let headers: [String: String]
    public let queryParams: [String: String]

    @objc public init(headers: [String: String], queryParams: [String: String]) {
        self.headers = headers
        self.queryParams = queryParams
    }
}
