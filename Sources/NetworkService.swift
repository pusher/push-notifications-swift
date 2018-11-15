import Foundation

class NetworkService: PushNotificationsNetworkable {

    let session: URLSession
    let queue = DispatchQueue(label: Constants.DispatchQueue.networkQueue)

    init(session: URLSession) {
        self.session = session
    }

    // MARK: PushNotificationsNetworkable
    func register(url: URL, deviceToken: Data, instanceId: String, completion: @escaping CompletionHandler<Device>) {
        let deviceTokenString = deviceToken.hexadecimalRepresentation()
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""

        let metadata = Metadata.update()

        guard let body = try? Register(token: deviceTokenString, instanceId: instanceId, bundleIdentifier: bundleIdentifier, metadata: metadata).encode() else {
            return
        }
        let request = self.setRequest(url: url, httpMethod: .POST, body: body)

        self.networkRequest(request, session: self.session) { (response) in
            guard let device = try? JSONDecoder().decode(Device.self, from: response) else {
                return
            }
            completion(device)
        }
    }

    func subscribe(url: URL, completion: @escaping CompletionHandler<String>) {
        let request = self.setRequest(url: url, httpMethod: .POST)

        self.networkRequest(request, session: self.session) { _ in
            completion(nil)
        }
    }

    func setSubscriptions(url: URL, interests: [String], completion: @escaping CompletionHandler<String>) {
        guard let body = try? Interests(interests: interests).encode() else {
            return
        }
        let request = self.setRequest(url: url, httpMethod: .PUT, body: body)

        self.networkRequest(request, session: self.session) { _ in
            completion(nil)
        }
    }

    func unsubscribe(url: URL, completion: @escaping CompletionHandler<String>) {
        let request = self.setRequest(url: url, httpMethod: .DELETE)

        self.networkRequest(request, session: self.session) { _ in
            completion(nil)
        }
    }

    func track(url: URL, eventType: ReportEventType, completion: @escaping CompletionHandler<String>) {
        guard let body = try? eventType.encode() else {
            return
        }

        let request = self.setRequest(url: url, httpMethod: .POST, body: body)
        self.networkRequest(request, session: self.session) { _ in
            completion(nil)
        }
    }

    func syncMetadata(url: URL, completion: @escaping CompletionHandler<String>) {
        guard let metadataDictionary = Metadata.load() else {
            return
        }
        let metadata = Metadata(propertyListRepresentation: metadataDictionary)
        if metadata.hasChanged() {
            let updatedMetadataObject = Metadata.update()
            guard let body = try? updatedMetadataObject.encode() else {
                return
            }
            let request = self.setRequest(url: url, httpMethod: .PUT, body: body)
            self.networkRequest(request, session: self.session) { _ in
                completion(nil)
            }
        }
    }

    func setUserId(url: URL, token: String, completion: @escaping CompletionHandler<String>) {
        var request = self.setRequest(url: url, httpMethod: .PUT)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        self.networkRequest(request, session: self.session) { _ in
            completion(nil)
        }
    }

    func deleteDevice(url: URL, completion: @escaping CompletionHandler<String>) {
        let request = self.setRequest(url: url, httpMethod: .DELETE)
        self.networkRequest(request, session: self.session) { _ in
            completion(nil)
        }
    }

    // MARK: Networking Layer
    private func networkRequest(_ request: URLRequest, session: URLSession, completion: @escaping (_ response: Data) -> Void) {
        self.queue.async {
            self.queue.suspend()

            func networkRequestWithExponentialBackoff(numberOfAttempts: Int = 0) {
                session.dataTask(with: request, completionHandler: { (data, response, error) in
                    guard
                        let data = data,
                        let httpURLResponse = response as? HTTPURLResponse
                    else {
                        Thread.sleep(forTimeInterval: TimeInterval(self.calculateExponentialBackoffMs(attemptCount: numberOfAttempts) / 1000.0))
                        return networkRequestWithExponentialBackoff(numberOfAttempts: numberOfAttempts + 1)
                    }
                    let statusCode = httpURLResponse.statusCode
                    guard statusCode >= 200 && statusCode < 300, error == nil else {
                        if let reason = try? JSONDecoder().decode(Reason.self, from: data) {
                            print("[PushNotifications]: \(reason.description)")
                        }

                        Thread.sleep(forTimeInterval: TimeInterval(self.calculateExponentialBackoffMs(attemptCount: numberOfAttempts) / 1000.0))
                        return networkRequestWithExponentialBackoff(numberOfAttempts: numberOfAttempts + 1)
                    }

                    self.queue.resume()

                    completion(data)

                }).resume()
            }

            networkRequestWithExponentialBackoff()
        }
    }

    private let maxExponentialBackoffDelayMs = 32000.0
    private let baseExponentialBackoffDelayMs = 200.0
    private func calculateExponentialBackoffMs(attemptCount: Int) -> Double {
        return min(maxExponentialBackoffDelayMs, baseExponentialBackoffDelayMs * pow(2.0, Double(attemptCount)))
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
