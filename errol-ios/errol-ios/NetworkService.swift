import Foundation

struct NetworkService: PusherRegisterable, PusherSubscribable {

    let url: URL
    let session: URLSession

    typealias NetworkCompletionHandler = (_ response: NetworkResponse) -> Void

    func register() {
        // TODO
    }

    func subscribe(interest: String) {
        //TODO
    }

    private func postRequest(url: URL, session: URLSession, completion: @escaping NetworkCompletionHandler) {
        let request = self.setRequest(url: url)
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil
                else { return completion(NetworkResponse.Failure) }

            completion(NetworkResponse.Success(data: data))

        }).resume()
    }

    private func setRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return request
    }
}
