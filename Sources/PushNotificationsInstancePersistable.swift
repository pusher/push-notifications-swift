import Foundation

protocol PushNotificationsInstancePersistable {
    func setStartJobHasBeenEnqueued(flag: Bool)
    func getStartJobHasBeenEnqueued() -> Bool

    func setUserIdHasBeenCalledWith(userId: String)
    func getUserIdPreviouslyCalledWith() -> String?

    func clear()
}


