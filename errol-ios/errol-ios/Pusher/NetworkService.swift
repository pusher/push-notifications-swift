import Foundation

struct NetworkService: PusherRegisterable, PusherSubscribable {

    let url: URL
    let session: URLSession

    typealias NetworkCompletionHandler = (_ response: NetworkResponse) -> Void

    //MARK: PusherRegisterable
    func register(deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let bodyString = "{\"platformType\": \"ppns\", \"token\": \"\(deviceTokenString)\"}"
        guard let body = bodyString.data(using: .utf8) else { return }
        let request = self.setRequest(url: self.url, httpMethod: .POST, body: body)

        self.networkRequest(request, session: self.session) { (response) in
            print(response)
        }
    }

    //MARK: PusherSubscribable
    func subscribe(interest: String) {
        //TODO
    }

    func unsubscribe(interest: String) {
        //TODO
    }

    //MARK: Networking Layer
    private func networkRequest(_ request: URLRequest, session: URLSession, completion: @escaping NetworkCompletionHandler) {
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil
                else { return completion(NetworkResponse.Failure(response: response!)) }

            completion(NetworkResponse.Success(data: data))

        }).resume()
    }

    private func setRequest(url: URL, httpMethod: HTTPMethod, body: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body

        return request
    }
}
