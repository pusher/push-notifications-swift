import Foundation

@objc public protocol TokenProvider {
    func fetchToken(userId: String, completionHandler completion: @escaping (String, Error?) -> Void)
}
