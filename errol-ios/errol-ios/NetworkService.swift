import Foundation

struct NetworkService: PusherRegisterable, PusherSubscribable {

    let url: URL
    let session: URLSession

    typealias NetworkCompletionHandler = (_ response: NetworkResponse) -> Void

    func register(deviceToken: String) {
        let bodyString = "{\"platformType\": \"apns\", \"token\": \"dssss\"}"
        let body = bodyString.data(using: .utf8)!
        let request = self.setRequest(url: self.url, body: body)

        self.postRequest(request: request, session: self.session) { (response) in
            print(response)
        }
    }

    func subscribe(interest: String) {
        //TODO
    }

    private func postRequest(request: URLRequest, session: URLSession, completion: @escaping NetworkCompletionHandler) {
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil
                else { return completion(NetworkResponse.Failure) }

            completion(NetworkResponse.Success(data: data))

        }).resume()
    }

    private func setRequest(url: URL, body: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body

        return request
    }
}
