import Foundation

struct PublishId {
    let id: String?

    init(userInfo: [AnyHashable: Any]) {
        let data = userInfo["data"] as? [String: Any]
        let pusher = data?["pusher"] as? [String: Any]
        self.id = pusher?["publishId"] as? String
    }
}
