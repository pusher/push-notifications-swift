import Foundation

class NetworkService: PushNotificationsNetworkable {

    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    // MARK: PushNotificationsNetworkable
    func register(url: URL, deviceToken: Data, instanceId: String) -> Result<Device, Error> {
        let deviceTokenString = deviceToken.hexadecimalRepresentation()
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""

        let metadata = Metadata.update()

        guard let body = try? Register(token: deviceTokenString, instanceId: instanceId, bundleIdentifier: bundleIdentifier, metadata: metadata).encode() else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while encoding register payload."))
        }
        let request = self.setRequest(url: url, httpMethod: .POST, body: body)

        switch self.networkRequest(request, session: self.session) {
        case .value(let response):
            guard let device = try? JSONDecoder().decode(Device.self, from: response) else {
                return .error(PushNotificationsError.error("[PushNotifications] - Error while encoding device payload."))
            }
            return .value(device)
        case .error(let error):
            return .error(error)
        }
    }

    func subscribe(url: URL) -> Result<Void, Error> {
        let request = self.setRequest(url: url, httpMethod: .POST)

        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    func setSubscriptions(url: URL, interests: [String]) -> Result<Void, Error> {
        guard let body = try? Interests(interests: interests).encode() else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while encoding the interests payload."))
        }
        let request = self.setRequest(url: url, httpMethod: .PUT, body: body)

        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    func unsubscribe(url: URL) -> Result<Void, Error> {
        let request = self.setRequest(url: url, httpMethod: .DELETE)

        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    func track(url: URL, eventType: ReportEventType) -> Result<Void, Error> {
        guard let body = try? eventType.encode() else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while encoding the event type payload."))
        }

        let request = self.setRequest(url: url, httpMethod: .POST, body: body)
        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    func syncMetadata(url: URL) -> Result<Void, Error> {
        guard let metadataDictionary = Metadata.load() else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while loading the metadata."))
        }
        let metadata = Metadata(propertyListRepresentation: metadataDictionary)
        if metadata.hasChanged() {
            let updatedMetadataObject = Metadata.update()
            guard let body = try? updatedMetadataObject.encode() else {
                return .error(PushNotificationsError.error("[PushNotifications] - Error while encoding the metadata payload."))
            }
            let request = self.setRequest(url: url, httpMethod: .PUT, body: body)
            switch self.networkRequest(request, session: self.session) {
            case .value:
                return .value(())
            case .error(let error):
                return .error(error)
            }
        }

        return .value(())
    }

    func setUserId(url: URL, token: String) -> Result<Void, Error> {
        var request = self.setRequest(url: url, httpMethod: .PUT)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    func deleteDevice(url: URL) -> Result<Void, Error> {
        let request = self.setRequest(url: url, httpMethod: .DELETE)
        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    func getDevice(url: URL) -> Result<Void, Error> {
        let request = self.setRequest(url: url, httpMethod: .GET)
        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    // MARK: Networking Layer
    //TODO: Support retry strategy
    private func networkRequest(_ request: URLRequest, session: URLSession) -> Result<Data, Error> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Data, Error>?

        session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard
                let data = data,
                let httpURLResponse = response as? HTTPURLResponse
            else {
                result = .error(PushNotificationsError.error("Error!"))
                semaphore.signal()
                return
            }

            if error != nil {
                result = .error(PushNotificationsError.error("\(String(describing: error?.localizedDescription))"))
                semaphore.signal()
                return
            }

            let statusCode = httpURLResponse.statusCode

            if 400..<500 ~= statusCode {
                if let reason = try? JSONDecoder().decode(Reason.self, from: data) {
                    print("[PushNotifications]: Request failed due to: \(reason.description), skipping it.")
                    result = .error(PushNotificationsError.error("Error!"))
                    semaphore.signal()
                    return
                }
            } else if statusCode >= 500 {
                if let reason = try? JSONDecoder().decode(Reason.self, from: data) {
                    print("[PushNotifications]: \(reason.description)")
                    result = .error(PushNotificationsError.error("Error!"))
                    semaphore.signal()
                    return
                }
            }

            result = .value(data)
            semaphore.signal()
        }).resume()

        semaphore.wait()
        return result!
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
