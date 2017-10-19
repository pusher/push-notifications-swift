import Foundation

protocol PusherSubscribable {
    func subscribe(interest: String)
    func unsubscribe(interest: String)
}

extension PusherSubscribable {
    func subscribe(interest: String) {}
    func unsubscribe(interest: String) {}
}
