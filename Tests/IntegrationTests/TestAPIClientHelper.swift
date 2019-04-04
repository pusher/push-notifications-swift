import Foundation

struct Interests: Codable {
    let interests: [String]
}

struct TestAPIClientHelper {
    func getDeviceInterests(instanceId: String, deviceId: String) -> [String]? {
        let session = URLSession.init(configuration: .ephemeral)
        let semaphore = DispatchSemaphore(value: 0)
        var interests: Interests? = nil

        let request = setRequest(url: URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)/interests")!, httpMethod: .GET)
        session.dataTask(with: request) { (data, urlResponse, error) in
            interests = try? JSONDecoder().decode(Interests.self, from: data!)
            semaphore.signal()
        }.resume()

        semaphore.wait()
        return interests?.interests
    }

    func deleteDevice(instanceId: String, deviceId: String) {
        let session = URLSession.init(configuration: .ephemeral)
        let semaphore = DispatchSemaphore(value: 0)

        let request = setRequest(url: URL(string: "https://\(instanceId).pushnotifications.pusher.com/device_api/v1/instances/\(instanceId)/devices/apns/\(deviceId)")!, httpMethod: .DELETE)
        session.dataTask(with: request) { (data, urlResponse, error) in
            semaphore.signal()
        }.resume()

        semaphore.wait()
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
