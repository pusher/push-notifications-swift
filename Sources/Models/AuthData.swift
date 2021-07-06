import Foundation

/// Authentication data that is provided to a `TokenProvider`, such as `BeamsTokenProvider`.
@objc public class AuthData: NSObject {

    /// The headers to attach to the `URLRequest` triggered by the `TokenProvider` when calling `fetchToken(userId:completion:)`.
    public let headers: [String: String]

    /// The query parameters to attach to the `URLRequest` triggered by the `TokenProvider` when calling `fetchToken(userId:completion:)`.
    public let queryParams: [String: String]

    /// Create an `AuthData` instance based on some `headers` and `queryParams`.
    /// - Parameters:
    ///   - headers: A `Dictionary` of header key / value pairs.
    ///   - queryParams: A `Dictionary` of query parameters key / value pairs.
    @objc public init(headers: [String: String], queryParams: [String: String]) {
        self.headers = headers
        self.queryParams = queryParams
    }
}
