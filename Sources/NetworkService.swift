import Foundation

struct NetworkService: ErrolRegisterable, ErrolSubscribable {

    let url: URL
    let session: URLSession

    typealias NetworkCompletionHandler = (_ response: NetworkResponse) -> Void

    //MARK: ErrolRegisterable
    func register(deviceToken: Data, completion: @escaping CompletionHandler) {
        let deviceTokenString = deviceToken.hexadecimalRepresentation()
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
        let bodyString = "{\"token\": \"\(deviceTokenString)\", \"bundleIdentifier\": \"\(bundleIdentifier)\"}"
        guard let body = bodyString.data(using: .utf8) else { return }
        let request = self.setRequest(url: self.url, httpMethod: .POST, body: body)

        self.networkRequest(request, session: self.session) { (response) in
            switch response {
            case .Success(let data):
                guard let device = try? JSONDecoder().decode(Device.self, from: data) else { return }
                completion(device.id)
            case .Failure(let data):
                print(data)
            }
        }
    }

    //MARK: ErrolSubscribable
    func subscribe(completion: @escaping () -> Void = {}) {
        let request = self.setRequest(url: self.url, httpMethod: .POST)

        self.networkRequest(request, session: self.session) { (response) in
            completion()
        }
    }

    func unsubscribe(completion: @escaping () -> Void = {}) {
        let request = self.setRequest(url: self.url, httpMethod: .DELETE)

        self.networkRequest(request, session: self.session) { (response) in
            completion()
        }
    }

    //MARK: Networking Layer
    private func networkRequest(_ request: URLRequest, session: URLSession, completion: @escaping NetworkCompletionHandler) {
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let data = data else { return }
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200, error == nil
            else {
                guard let reason = try? JSONDecoder().decode(Reason.self, from: data) else { return }
                return completion(NetworkResponse.Failure(description: reason.description))
            }

            completion(NetworkResponse.Success(data: data))

        }).resume()
    }

    private func setRequest(url: URL, httpMethod: HTTPMethod, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body

        return request
    }
}
