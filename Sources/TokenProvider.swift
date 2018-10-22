import Foundation

protocol TokenProvider {
    func fetchToken(completion: @escaping (_ response: Data) -> Void)
}
