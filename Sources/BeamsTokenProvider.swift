import Foundation

enum BeamsTokenProviderError: Error {
    case error(String)
}

@objc public class BeamsTokenProvider: NSObject, TokenProvider {
    public let authURL: String
    public let getAuthData: () -> AuthData

    public init(authURL: String, getAuthData: @escaping () -> (AuthData)) {
        self.authURL = authURL
        self.getAuthData = getAuthData
    }

    func fetchToken(userId: String, completion: @escaping (Result<String>) -> Void) {
        let authData = getAuthData()
        let headers = authData.headers

        let urlSession = URLSession(configuration: .ephemeral)

        guard var components = URLComponents(string: authURL) else {
            return completion(.failure(BeamsTokenProviderError.error("URL string from the `authURL` is malformed.")))
        }

        let userIdQueryItem = URLQueryItem(name: "user_id", value: userId)
        components.queryItems = [userIdQueryItem]
        guard let url = components.url else {
            return completion(.failure(BeamsTokenProviderError.error("There was a problem constructing URL from the `authURL`.")))
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        for header in headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }

        urlSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard let data = data else {
                return completion(.failure(BeamsTokenProviderError.error("[PushNotifications] - BeamsTokenProvider: Token is nil")))
            }
            guard let httpURLResponse = response as? HTTPURLResponse else {
                return completion(.failure(BeamsTokenProviderError.error("[PushNotifications] - BeamsTokenProvider: Error while casting response object to `HTTPURLResponse`")))
            }
            let statusCode = httpURLResponse.statusCode
            guard statusCode >= 200 && statusCode < 300 else {
                return completion(.failure(BeamsTokenProviderError.error("[PushNotifications] - BeamsTokenProvider: Received HTTP Status Code: \(statusCode)")))
            }
            guard error == nil else {
                return completion(.failure(BeamsTokenProviderError.error("[PushNotifications] - BeamsTokenProvider: \(error.debugDescription)")))
            }

            guard let token = try? JSONDecoder().decode(Token.self, from: data).token else {
                return completion(.failure(BeamsTokenProviderError.error("[PushNotifications] - BeamsTokenProvider: Error while parsing the token.")))
            }

            return completion(.success(token))
        }).resume()
    }
}
