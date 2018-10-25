import Foundation

protocol TokenProvider {
    func fetchToken(userId: String, completion: @escaping (Result<String>) -> Void)
}
