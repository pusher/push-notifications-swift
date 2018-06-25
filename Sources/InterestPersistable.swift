import Foundation

protocol InterestPersistable {
    @discardableResult func persist(interest: String) -> Bool
    @discardableResult func persist(interests: Array<String>) -> Bool
    @discardableResult func remove(interest: String) -> Bool
    func removeAll()
    func getSubscriptions() -> Array<String>?
}
