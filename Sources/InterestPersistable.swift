import Foundation

protocol InterestPersistable {
    @discardableResult func persist(interest: String) -> Bool
    func persist(interests: Array<String>)
    @discardableResult func remove(interest: String) -> Bool
    func removeAll()
    func getSubscriptions() -> Array<String>?
}
