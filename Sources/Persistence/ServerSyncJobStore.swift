import Foundation

struct ServerSyncJobStore {
    private let instanceId: String
    private let syncJobStoreFileName: String
    private let fileManager = FileManager.default
    private var jobStoreArray: [ServerSyncJob] = []
    private let syncJobStoreQueue = DispatchQueue(label: "com.pusher.beams.syncJobStoreQueue")

    init(instanceId: String) {
        self.instanceId = instanceId
        self.syncJobStoreFileName = "\(self.instanceId)-syncJobStore"
        
        self.jobStoreArray = self.loadOperations()
    }

    // https://stackoverflow.com/a/46369152
    private struct FailableDecodable<Base : Decodable> : Decodable {
        let base: Base?
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.base = try? container.decode(Base.self)
        }
    }

    private func loadOperations() -> [ServerSyncJob] {
        guard let fileURL = try? fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return []
        }

        let filePath = fileURL.appendingPathComponent(syncJobStoreFileName)

        guard let operations = NSData(contentsOfFile: filePath.relativePath) else {
            // Assuming a fresh installation here
            return []
        }

        let jsonDecoder = JSONDecoder()
        guard let operationsArray = try? jsonDecoder.decode([FailableDecodable<ServerSyncJob>].self, from: (operations as Data)) else {
            print("[PushNotifications] - Failed to load previously stored operations, continuing without them.")
            return []
        }

        return operationsArray.compactMap { $0.base }
    }

    private func persistOperations(_ jobStoreArray: [ServerSyncJob]) {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(jobStoreArray) else {
            print("[PushNotifications] - Failed to encode operations, continuing without persisting them.")
            return
        }

        guard let fileURL = try? fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return
        }

        var filePath = fileURL.appendingPathComponent(syncJobStoreFileName)

        do {
            try (data as NSData).write(toFile: filePath.relativePath, options: .atomic)

            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try? filePath.setResourceValues(resourceValues)
        } catch {
            print("[PushNotifications] - Failed to persist operations, continuing ...")
        }
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
            self.persistOperations(self.jobStoreArray)
        }
    }

    mutating func removeFirst() {
        syncJobStoreQueue.sync {
            if (self.jobStoreArray.count > 0) {
                self.jobStoreArray.removeFirst()
                self.persistOperations(self.jobStoreArray)
            }
        }
    }
}
