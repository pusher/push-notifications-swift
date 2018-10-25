import Foundation

@objc public class BeamsTokenProvider: NSObject, TokenProvider {
    public let authURL: String
    public let getAuthData: () -> AuthData

    public init(authURL: String, getAuthData: @escaping () -> (AuthData)) {
        self.authURL = authURL
        self.getAuthData = getAuthData
    }

    func fetchToken(userId: String, completion: @escaping (_ response: String) -> Void) {
        let authData = getAuthData()
        let headers = authData.headers

        let urlSession = URLSession(configuration: .ephemeral)

        guard var components = URLComponents(string: authURL) else {
            print("URL string from the `authURL` is malformed.")
            return
        }

        let userIdQueryItem = URLQueryItem(name: "user_id", value: userId)
        components.queryItems = [userIdQueryItem]
        guard let url = components.url else {
            print("There was a problem constructing URL from the `authURL`.")
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        for header in headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }

        urlSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard
                let token = data,
                let httpURLResponse = response as? HTTPURLResponse
                else {
                    print("[PushNotifications] - BeamsTokenProvider: Something went wrong ...")
                    return completion("")
            }
            let statusCode = httpURLResponse.statusCode
            guard statusCode >= 200 && statusCode < 300, error == nil else {
                print("[PushNotifications] - BeamsTokenProvider: Received HTTP Status Code: \(statusCode)")
                return completion("")
            }

            return completion(String(data: token, encoding: .utf8) ?? "Something went wrong ...")
        }).resume()
    }
}
