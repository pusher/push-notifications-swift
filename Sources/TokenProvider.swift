import Foundation

protocol TokenProvider {
    func fetchToken(userId: String, completion: @escaping (_ response: String) -> Void)
}
