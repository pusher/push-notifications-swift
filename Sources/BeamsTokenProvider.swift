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

        var urlRequest = URLRequest(url: URL(string: "\(self.authURL)?user_id=\(userId)")!)
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
