import Foundation

/// Used to generate tokens for users to authenticate against.
@objc public final class BeamsTokenProvider: NSObject, TokenProvider {

    /// The authentication endpoint URL `String`.
    public let authURL: String

    /// A closure that returns an `AuthData` object.
    public let getAuthData: () -> AuthData

    /// Creates a `BeamsTokenProvider` instance.
    /// - Parameters:
    ///   - authURL: The authentication endpoint URL `String`.
    ///   - getAuthData: A closure that returns an `AuthData` object.
    @objc public init(authURL: String, getAuthData: @escaping () -> (AuthData)) {
        self.authURL = authURL
        self.getAuthData = getAuthData
    }

    /// Fetch a token for a given user to authenticate against.
    /// - Parameters:
    ///   - userId: The user ID `String`.
    ///   - completion: A closure containing a valid token `String` or an `Error`.
    public func fetchToken(userId: String, completionHandler completion: @escaping (String, Error?) -> Void) throws {
        let authData = getAuthData()
        let headers = authData.headers
        let queryParams = authData.queryParams

        let urlSession = URLSession(configuration: .ephemeral)

        guard var components = URLComponents(string: authURL) else {
            return completion("", TokenProviderError.error("URL string from the `authURL` is malformed."))
        }

        var queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        queryItems.append(URLQueryItem(name: "user_id", value: userId))
        components.queryItems = queryItems
        guard let url = components.url else {
            return completion("", TokenProviderError.error("There was a problem constructing URL from the `authURL`."))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        for header in headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }

        urlSession.dataTask(with: urlRequest, completionHandler: { data, response, error in
            guard let data = data else {
                return completion("", TokenProviderError.error("[PushNotifications] - BeamsTokenProvider: Token is nil"))
            }
            guard let httpURLResponse = response as? HTTPURLResponse else {
                return completion("", TokenProviderError.error("[PushNotifications] - BeamsTokenProvider: Error while casting response object to `HTTPURLResponse`"))
            }
            let statusCode = httpURLResponse.statusCode
            guard statusCode >= 200 && statusCode < 300 else {
                return completion("", TokenProviderError.error("[PushNotifications] - BeamsTokenProvider: Received HTTP Status Code: \(statusCode)"))
            }
            guard error == nil else {
                return completion("", TokenProviderError.error("[PushNotifications] - BeamsTokenProvider: \(error.debugDescription)"))
            }

            guard let token = try? JSONDecoder().decode(Token.self, from: data).token else {
                return completion("", TokenProviderError.error("[PushNotifications] - BeamsTokenProvider: Error while parsing the token."))
            }

            return completion(token, nil)
        }).resume()
    }
}
