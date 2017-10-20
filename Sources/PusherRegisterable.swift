import Foundation

protocol PusherRegisterable {
    typealias CompletionHandler = (String) -> ()
    func register(deviceToken: Data, completion: @escaping CompletionHandler)
}
