import Foundation

struct NetworkService: PushNotificationsNetworkable {

    let url: URL
    let session: URLSession

    typealias NetworkCompletionHandler = (_ response: NetworkResponse) -> Void

    // MARK: PushNotificationsRegisterable
    func register(deviceToken: Data, completion: @escaping (String) -> Void) {
        let deviceTokenString = deviceToken.hexadecimalRepresentation()
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
        let bodyString = "{\"token\": \"\(deviceTokenString)\", \"bundleIdentifier\": \"\(bundleIdentifier)\"}"
        let body = Data(bodyString.utf8)
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

    // MARK: PushNotificationsSubscribable
    func subscribe(completion: @escaping () -> Void = {}) {
        let request = self.setRequest(url: self.url, httpMethod: .POST)

        self.networkRequest(request, session: self.session) { (response) in
            completion()
        }
    }

    func setSubscriptions(interests: Array<String>, completion: @escaping () -> Void = {}) {
        let bodyString = "{\"interests\": \(interests)}"
        let body = Data(bodyString.utf8)
        let request = self.setRequest(url: self.url, httpMethod: .PUT, body: body)

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

    func unsubscribeAll(completion: @escaping () -> Void = {}) {
        self.setSubscriptions(interests: [])
    }

    func track(userInfo: [AnyHashable : Any], completion: @escaping () -> Void = {}) {
        guard let publishId = PublishId(userInfo: userInfo).id else { return }
        let timestamp = Date().milliseconds()

        let bodyString = "{\"publishId\": \"\(publishId)\", \"timestampMs\": \"\(timestamp)\"}"
        let body = Data(bodyString.utf8)

        let request = self.setRequest(url: self.url, httpMethod: .POST, body: body)
        self.networkRequest(request, session: self.session) { (response) in
            completion()
        }
    }

    // MARK: Networking Layer
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
