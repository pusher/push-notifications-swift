import Foundation

struct ServerSyncJobStore {
    private let syncJobStore = "syncJobStore"
    private var jobStoreArray: [ServerSyncJob] = []
    private let syncJobStoreQueue = DispatchQueue(label: "syncJobStoreQueue")

    init() {
        self.jobStoreArray = self.loadOperations()
    }

    private func loadOperations() -> [ServerSyncJob] {
        guard let operations = NSData(contentsOfFile: syncJobStore) else {
            print("[PushNotifications] - Failed to load previously stored operations, continuing without them.")
            return []
        }

        let jsonDecoder = JSONDecoder()
        guard let operationsArray = try? jsonDecoder.decode([ServerSyncJob].self, from: (operations as Data)) else {
            print("[PushNotifications] - Failed to load previously stored operations, continuing without them.")
            return []
        }

        return operationsArray
    }

    var isEmpty: Bool {
        get {
            return syncJobStoreQueue.sync {
                return self.jobStoreArray.isEmpty
            }
        }
    }

    var first: ServerSyncJob? {
        get {
            return syncJobStoreQueue.sync {
                return jobStoreArray.first
            }
        }
    }

    func toList() -> [ServerSyncJob] {
        return syncJobStoreQueue.sync {
            return self.jobStoreArray
        }
    }

    mutating func append(_ job: ServerSyncJob) {
        syncJobStoreQueue.sync {
            self.jobStoreArray.append(job)

            let jsonEncoder = JSONEncoder()
            let data = try! jsonEncoder.encode(jobStoreArray)
            try! (data as NSData).write(toFile: syncJobStore, options: .atomic)
        }
    }

    mutating func removeFirst() {
        syncJobStoreQueue.sync {
            if (self.jobStoreArray.count > 0) {
                self.jobStoreArray.removeFirst()

                let jsonEncoder = JSONEncoder()
                let data = try! jsonEncoder.encode(jobStoreArray)
                try! (data as NSData).write(toFile: syncJobStore, options: .atomic)
            }
        }
    }
}
