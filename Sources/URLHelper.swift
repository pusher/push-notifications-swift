import Foundation

extension URL {
    func append(queryParameter: String) -> URL? {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)
        urlComponents?.query = queryParameter
        guard let url = urlComponents?.url else { return nil }
        return url
    }
}
