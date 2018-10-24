import Foundation

protocol UserPersistable {
    @discardableResult func setUserId(userId: String) -> Bool
    func getUserId() -> String?
    func removeUserId()
}
