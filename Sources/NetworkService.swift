import Foundation

struct NetworkService: PushNotificationsNetworkable {

    let url: URL
    let session: URLSession

    typealias NetworkCompletionHandler = (_ response: NetworkResponse) -> Void

    // MARK: PushNotificationsNetworkable
    func register(deviceToken: Data, instanceId: String, completion: @escaping CompletionHandler) {
        let deviceTokenString = deviceToken.hexadecimalRepresentation()
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""

        let metadata = Metadata.update()

        guard let body = try? Register(token: deviceTokenString, instanceId: instanceId, bundleIdentifier: bundleIdentifier, metadata: metadata).encode() else { return }
        let request = self.setRequest(url: self.url, httpMethod: .POST, body: body)

        self.networkRequest(request, session: self.session) { (response) in
            switch response {
            case .Success(let data):
                guard let device = try? JSONDecoder().decode(Device.self, from: data) else { return }
                completion(device.id, true)
            case .Failure(let data):
                guard let reason = try? JSONDecoder().decode(Reason.self, from: data) else { return }

                print(reason.description)
                completion(nil, false)
            }
        }
    }

    func subscribe(completion: @escaping CompletionHandler) {
        let request = self.setRequest(url: self.url, httpMethod: .POST)

        self.networkRequest(request, session: self.session) { (response) in
            switch response {
            case .Success(_):
                completion(nil, true)
            case .Failure(_):
                completion(nil, false)
            }
        }
    }

    func setSubscriptions(interests: Array<String>, completion: @escaping CompletionHandler) {
        guard let body = try? Interests(interests: interests).encode() else { return }
        let request = self.setRequest(url: self.url, httpMethod: .PUT, body: body)

        self.networkRequest(request, session: self.session) { (response) in
            switch response {
            case .Success(_):
                completion(nil, true)
            case .Failure(_):
                completion(nil, false)
            }
        }
    }

    func unsubscribe(completion: @escaping CompletionHandler) {
        let request = self.setRequest(url: self.url, httpMethod: .DELETE)

        self.networkRequest(request, session: self.session) { (response) in
            switch response {
            case .Success(_):
                completion(nil, true)
            case .Failure(_):
                completion(nil, false)
            }
        }
    }

    func unsubscribeAll(completion: @escaping CompletionHandler) {
        self.setSubscriptions(interests: [], completion: completion)
    }

    func track(eventType: ReportEventType, completion: @escaping CompletionHandler) {
        guard let body = try? eventType.encode() else { return }

        let request = self.setRequest(url: self.url, httpMethod: .POST, body: body)
        self.networkRequest(request, session: self.session) { (response) in
            switch response {
            case .Success(_):
                completion(nil, true)
            case .Failure(_):
                completion(nil, false)
            }
        }
    }

    func syncMetadata(completion: @escaping CompletionHandler) {
        guard let metadataDictionary = Metadata.load() else { return }
        let metadata = Metadata(propertyListRepresentation: metadataDictionary)
        if metadata.hasChanged() {
            let updatedMetadataObject = Metadata.update()
            guard let body = try? updatedMetadataObject.encode() else { return }
            let request = self.setRequest(url: self.url, httpMethod: .PUT, body: body)
            self.networkRequest(request, session: self.session) { (response) in
                switch response {
                case .Success(_):
                    completion(nil, true)
                case .Failure(_):
                    completion(nil, false)
                }
            }
        }
    }

    // MARK: Networking Layer
    private func networkRequest(_ request: URLRequest, session: URLSession, completion: @escaping NetworkCompletionHandler) {
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard
                let data = data,
                let httpURLResponse = response as? HTTPURLResponse
            else { return }

            let statusCode = httpURLResponse.statusCode
            guard statusCode >= 200 && statusCode < 300, error == nil else {
                return completion(NetworkResponse.Failure(data: data))
            }

            completion(NetworkResponse.Success(data: data))

        }).resume()
    }

    private func setRequest(url: URL, httpMethod: HTTPMethod, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("push-notifications-swift \(SDK.version)", forHTTPHeaderField: "X-Pusher-Library")
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body

        return request
    }
}
