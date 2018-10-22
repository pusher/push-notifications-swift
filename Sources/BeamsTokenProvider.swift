import Foundation

@objc public class BeamsTokenProvider: NSObject, TokenProvider {
    public let authURL: String
    public let getAuthData: () -> AuthData

    public init(authURL: String, getAuthData: @escaping () -> (AuthData)) {
        self.authURL = authURL
        self.getAuthData = getAuthData
    }

    func fetchToken(completion: @escaping (_ response: Data) -> Void) {
        let authData = getAuthData()
        let headers = authData.headers

        let urlSession = URLSession(configuration: .ephemeral)

        var urlRequest = URLRequest(url: URL(string: self.authURL)!)
        urlRequest.httpMethod = "POST"
        for header in headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }

        urlSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            guard
                let data = data,
                let httpURLResponse = response as? HTTPURLResponse
                else {
                    return
            }
            let statusCode = httpURLResponse.statusCode
            guard statusCode >= 200 && statusCode < 300, error == nil else {
                    return
            }

            return completion(data)
        }).resume()
    }
}
