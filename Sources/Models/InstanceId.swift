import Foundation

struct InstanceId {
    let id: String

    init?(userInfo: [AnyHashable: Any]) {
        let data = userInfo["data"] as? [String: Any]
        let pusher = data?["pusher"] as? [String: Any]
        if let instanceId = pusher?["instanceId"] as? String {
            self.id = instanceId
        } else {
            return nil
        }
    }
}
