import Foundation

protocol ErrolRegisterable {
    typealias CompletionHandler = (String) -> ()
    func register(deviceToken: Data, completion: @escaping CompletionHandler)
}
