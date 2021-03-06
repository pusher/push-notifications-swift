import Foundation
@testable import PushNotifications

struct Interests: Codable {
    let interests: [String]
}

struct TestDevice: Codable {
    let id: String
    let userId: String
    let metadata: Metadata
}

struct TestAPIClientHelper {
    func getDeviceInterests(instanceId: String, deviceId: String) -> [String]? {
        let session = URLSession(configuration: .ephemeral)
        let semaphore = DispatchSemaphore(value: 0)
        var interests: Interests?

        let request = setRequest(url: URL.PushNotifications.interests(instanceId: instanceId,
                                                                      deviceId: deviceId)!,
                                 httpMethod: .GET)
        session.dataTask(with: request) { data, _, _ in
            interests = try? JSONDecoder().decode(Interests.self, from: data!)
            semaphore.signal()
        }.resume()

        semaphore.wait()
        return interests?.interests
    }

    func deleteDevice(instanceId: String, deviceId: String) {
        let session = URLSession(configuration: .ephemeral)
        let semaphore = DispatchSemaphore(value: 0)

        let request = setRequest(url: URL.PushNotifications.device(instanceId: instanceId,
                                                                   deviceId: deviceId)!,
                                 httpMethod: .DELETE)
        session.dataTask(with: request) { _, _, _ in
            semaphore.signal()
        }.resume()

        semaphore.wait()
    }

    func getDevice(instanceId: String, deviceId: String) -> TestDevice? {
        let session = URLSession(configuration: .ephemeral)
        let semaphore = DispatchSemaphore(value: 0)
        var device: TestDevice?

        let request = setRequest(url: URL.PushNotifications.device(instanceId: instanceId,
                                                                   deviceId: deviceId)!,
                                 httpMethod: .GET)
        session.dataTask(with: request) { data, _, _ in
            device = try? JSONDecoder().decode(TestDevice.self, from: data!)
            semaphore.signal()
        }.resume()

        semaphore.wait()
        return device
    }

    func setRequest(url: URL, httpMethod: HTTPMethod, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body

        return request
    }

    enum HTTPMethod: String {
        case DELETE
        case GET
        case POST
        case PUT
    }
}
