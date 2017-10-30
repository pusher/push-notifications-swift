import Foundation

protocol ErrolSubscribable {
    func subscribe(completion: @escaping () -> Void)
    func unsubscribe(completion: @escaping () -> Void)
}
