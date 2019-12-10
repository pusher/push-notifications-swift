import Foundation

struct Constants {
    struct DispatchQueue {
        static let preIISOperationQueue = "com.pusher.pushnotifications.pre.iis.operation.queue"
        static let persistenceStorageOperationQueue = "com.pusher.pushnotifications.persistence.storage.operation.queue"
    }

    struct ReportEventType {
        static let open = "Open"
        static let delivery = "Delivery"
    }
}
