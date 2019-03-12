import Foundation

class NetworkService: PushNotificationsNetworkable {
    let session: URLSession
    let baseDeviceAPIURL: String
    let baseReportingAPIURL: String

    init(session: URLSession, instanceId: String) {
        self.session = session
        self.baseDeviceAPIURL = "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)"
        self.baseReportingAPIURL = "https://\(instanceId).pushnotifications.pusher.com/reporting_api/v2/instances/\(instanceId)"
    }

    // MARK: PushNotificationsNetworkable
    func register(deviceToken: String, metadata: Metadata) -> Result<Device, Error> {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""

        guard let body = try? Register(token: deviceToken, bundleIdentifier: bundleIdentifier, metadata: metadata).encode() else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while encoding register payload."))
        }

        guard let url = URL(string: "\(self.baseDeviceAPIURL)/devices/apns") else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while constructing the URL"))
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

    func subscribe(deviceId: String, interest: String) -> Result<Void, Error> {
        guard let url = URL(string: "\(self.baseDeviceAPIURL)/devices/apns/\(deviceId)/interests/\(interest)") else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while constructing the URL"))
        }

        let request = self.setRequest(url: url, httpMethod: .POST)

        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    func setSubscriptions(deviceId: String, interests: [String]) -> Result<Void, Error> {
        guard let url = URL(string: "\(self.baseDeviceAPIURL)/devices/apns/\(deviceId)/interests") else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while constructing the URL"))
        }

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

    func unsubscribe(deviceId: String, interest: String) -> Result<Void, Error> {
        guard let url = URL(string: "\(self.baseDeviceAPIURL)/devices/apns/\(deviceId)/interests/\(interest)") else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while constructing the URL"))
        }

        let request = self.setRequest(url: url, httpMethod: .DELETE)

        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    func track(deviceId: String, eventType: ReportEventType) -> Result<Void, Error> {
        guard let url = URL(string: "\(self.baseReportingAPIURL)/events") else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while constructing the URL"))
        }

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

    func syncMetadata(deviceId: String, metadata: Metadata) -> Result<Void, Error> {
        guard let url = URL(string: "\(self.baseDeviceAPIURL)/devices/apns/\(deviceId)/metadata") else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while constructing the URL"))
        }

        guard let body = try? metadata.encode() else {
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

    func setUserId(deviceId: String, token: String) -> Result<Void, Error> {
        guard let url = URL(string: "\(self.baseDeviceAPIURL)/devices/apns/\(deviceId)/user") else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while constructing the URL"))
        }

        var request = self.setRequest(url: url, httpMethod: .PUT)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    func deleteDevice(deviceId: String) -> Result<Void, Error> {
        guard let url = URL(string: "\(self.baseDeviceAPIURL)/devices/apns/\(deviceId)") else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while constructing the URL"))
        }

        let request = self.setRequest(url: url, httpMethod: .DELETE)
        switch self.networkRequest(request, session: self.session) {
        case .value:
            return .value(())
        case .error(let error):
            return .error(error)
        }
    }

    func getDevice(deviceId: String) -> Result<Void, Error> {
        guard let url = URL(string: "\(self.baseDeviceAPIURL)/devices/apns/\(deviceId)") else {
            return .error(PushNotificationsError.error("[PushNotifications] - Error while constructing the URL"))
        }

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
