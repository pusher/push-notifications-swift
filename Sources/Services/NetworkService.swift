import Foundation

class NetworkService: PushNotificationsNetworkable {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    // MARK: PushNotificationsNetworkable
    func register(instanceId: String,
                  deviceToken: String,
                  metadata: Metadata,
                  retryStrategy: RetryStrategy) -> Result<Device, PushNotificationsAPIError> {
        return retryStrategy.retry {
            let bundleIdentifier = Bundle.main.bundleIdentifier ?? "missing-bundle-id"

            guard let body = try? Register(token: deviceToken,
                                           bundleIdentifier: bundleIdentifier,
                                           metadata: metadata).encode() else {
                return .failure(.genericError(reason: "Error while encoding register payload."))
            }

            guard let url = URL.PushNotifications.devices(instanceId: instanceId) else {
                return .failure(.genericError(reason: "Error while constructing the URL."))
            }

            let request = self.setRequest(url: url, httpMethod: .POST, body: body)

            switch self.networkRequest(request, session: self.session, retryStrategy: retryStrategy) {
            case .success(let response):
                guard let device = try? JSONDecoder().decode(Device.self, from: response) else {
                    return .failure(.genericError(reason: "Error while encoding device payload."))
                }
                return .success(device)

            case .failure(let error):
                return .failure(error)
            }
        }
    }

    func subscribe(instanceId: String,
                   deviceId: String,
                   interest: String,
                   retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError> {
        return retryStrategy.retry {
            guard let url = URL.PushNotifications.interest(instanceId: instanceId,
                                                           deviceId: deviceId,
                                                           interest: interest) else {
                return .failure(.genericError(reason: "Error while constructing the URL."))
            }

            let request = self.setRequest(url: url, httpMethod: .POST)

            switch self.networkRequest(request, session: self.session, retryStrategy: retryStrategy) {
            case .success:
                return .success(())

            case .failure(let error):
                return .failure(error)
            }
        }
    }

    func setSubscriptions(instanceId: String,
                          deviceId: String,
                          interests: [String],
                          retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError> {
        return retryStrategy.retry {
            guard let url = URL.PushNotifications.interests(instanceId: instanceId,
                                                            deviceId: deviceId) else {
                return .failure(.genericError(reason: "Error while constructing the URL."))
            }

            guard let body = try? Interests(interests: interests).encode() else {
                return .failure(.genericError(reason: "Error while encoding the interests payload."))
            }
            let request = self.setRequest(url: url, httpMethod: .PUT, body: body)

            switch self.networkRequest(request, session: self.session, retryStrategy: retryStrategy) {
            case .success:
                return .success(())

            case .failure(let error):
                return .failure(error)
            }
        }
    }

    func unsubscribe(instanceId: String,
                     deviceId: String,
                     interest: String,
                     retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError> {
        return retryStrategy.retry {
            guard let url = URL.PushNotifications.interest(instanceId: instanceId,
                                                           deviceId: deviceId,
                                                           interest: interest) else {
                return .failure(.genericError(reason: "Error while constructing the URL."))
            }

            let request = self.setRequest(url: url, httpMethod: .DELETE)

            switch self.networkRequest(request, session: self.session, retryStrategy: retryStrategy) {
            case .success:
                return .success(())

            case .failure(let error):
                return .failure(error)
            }
        }
    }

    func track(instanceId: String,
               deviceId: String,
               eventType: ReportEventType,
               retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError> {
        return retryStrategy.retry {
            guard let url = URL.PushNotifications.events(instanceId: instanceId) else {
                return .failure(.genericError(reason: "Error while constructing the URL."))
            }

            guard let body = try? eventType.encode() else {
                return .failure(.genericError(reason: "Error while encoding the event type payload."))
            }

            let request = self.setRequest(url: url, httpMethod: .POST, body: body)
            switch self.networkRequest(request, session: self.session, retryStrategy: retryStrategy) {
            case .success:
                return .success(())

            case .failure(let error):
                return .failure(error)
            }
        }
    }

    func syncMetadata(instanceId: String,
                      deviceId: String,
                      metadata: Metadata,
                      retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError> {
        return retryStrategy.retry {
            guard let url = URL.PushNotifications.metadata(instanceId: instanceId,
                                                           deviceId: deviceId) else {
                return .failure(.genericError(reason: "Error while constructing the URL."))
            }

            guard let body = try? metadata.encode() else {
                return .failure(.genericError(reason: "Error while encoding the metadata payload."))
            }
            let request = self.setRequest(url: url, httpMethod: .PUT, body: body)
            switch self.networkRequest(request, session: self.session, retryStrategy: retryStrategy) {
            case .success:
                return .success(())

            case .failure(let error):
                return .failure(error)
            }
        }
    }

    func setUserId(instanceId: String,
                   deviceId: String,
                   token: String,
                   retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError> {
        return retryStrategy.retry {
            guard let url = URL.PushNotifications.user(instanceId: instanceId,
                                                       deviceId: deviceId) else {
                return .failure(.genericError(reason: "Error while constructing the URL."))
            }

            var request = self.setRequest(url: url, httpMethod: .PUT)
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            switch self.networkRequest(request, session: self.session, retryStrategy: retryStrategy) {
            case .success:
                return .success(())

            case .failure(let error):
                return .failure(error)
            }
        }
    }

    func deleteDevice(instanceId: String,
                      deviceId: String,
                      retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError> {
        return retryStrategy.retry {
            guard let url = URL.PushNotifications.device(instanceId: instanceId,
                                                         deviceId: deviceId) else {
                return .failure(.genericError(reason: "Error while constructing the URL."))
            }

            let request = self.setRequest(url: url, httpMethod: .DELETE)
            switch self.networkRequest(request, session: self.session, retryStrategy: retryStrategy) {
            case .success:
                return .success(())

            case .failure(let error):
                return .failure(error)
            }
        }
    }

    func getDevice(instanceId: String,
                   deviceId: String,
                   retryStrategy: RetryStrategy) -> Result<Void, PushNotificationsAPIError> {
        return retryStrategy.retry {
            guard let url = URL.PushNotifications.device(instanceId: instanceId,
                                                         deviceId: deviceId) else {
                return .failure(.genericError(reason: "Error while constructing the URL."))
            }

            let request = self.setRequest(url: url, httpMethod: .GET)
            switch self.networkRequest(request, session: self.session, retryStrategy: retryStrategy) {
            case .success:
                return .success(())

            case .failure(let error):
                return .failure(error)
            }
        }
    }

    // MARK: Networking Layer
    private func networkRequest(_ request: URLRequest,
                                session: URLSession,
                                retryStrategy: RetryStrategy) -> Result<Data, PushNotificationsAPIError> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Data, PushNotificationsAPIError>?

        session.dataTask(with: request, completionHandler: { data, response, error in
            guard
                let data = data,
                let httpURLResponse = response as? HTTPURLResponse
            else {
                result = .failure(.genericError(reason: "Error!"))
                semaphore.signal()
                return
            }

            if error != nil {
                result = .failure(.genericError(reason: "\(error!.localizedDescription)"))
                semaphore.signal()
                return
            }

            let statusCode = httpURLResponse.statusCode
            switch statusCode {
            case 200..<300:
                result = .success(data)

            case 400:
                let reason = try? JSONDecoder().decode(Reason.self, from: data)

                result = .failure(.badRequest(reason: reason?.description  ?? "Unknown API error"))

            case 401, 403:
                let reason = try? JSONDecoder().decode(Reason.self, from: data)

                // Hack, until we add error codes in the server.
                if reason?.description.contains("device token") ?? false {
                    result = .failure(.badDeviceToken(reason: reason!.description))
                } else {
                    result = .failure(.badJWT(reason: reason?.description  ?? "Unknown API error"))
                }

            case 404:
                result = .failure(.deviceNotFound)

            default:
                let reason = try? JSONDecoder().decode(Reason.self, from: data)

                result = .failure(.genericError(reason: reason?.description  ?? "Unknown API error"))
            }

            semaphore.signal()
        }).resume()

        semaphore.wait()
        return result!
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
