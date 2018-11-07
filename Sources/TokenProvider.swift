import Foundation

public enum TokenProviderError: Error {
    case error(String)
}

@objc public protocol TokenProvider {
    func fetchToken(userId: String, completionHandler completion: @escaping (String, Error?) -> Void)
}
