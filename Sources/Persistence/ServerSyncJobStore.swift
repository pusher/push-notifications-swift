import Foundation

struct ServerSyncJobStore {

    private var jobStoreArray: [ServerSyncJob]

    init() {
        self.jobStoreArray = []

        self.jobStoreArray = self.loadOperations()
    }

    func loadOperations() -> [ServerSyncJob] {
        guard let operations = NSData(contentsOfFile: "store") else {
            return []
        }

        let jsonDecoder = JSONDecoder()
        guard let operationsArray = try? jsonDecoder.decode([ServerSyncJob].self, from: (operations as Data)) else {
            return []
        }

        return operationsArray
    }

    var isEmpty: Bool {
        get {
            return self.jobStoreArray.isEmpty
        }
    }

    var first: ServerSyncJob? {
        get {
            return jobStoreArray.first
        }
    }

    func toList() -> [ServerSyncJob] {
        return self.jobStoreArray
    }
    
    mutating func append(_ job: ServerSyncJob) {
        var operations = self.loadOperations()
        operations.append(job)
        if(self.jobStoreArray.count > 0) {
            self.jobStoreArray.removeAll()
        }

        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(operations) else {
            return
        }

        try! (data as NSData).write(toFile: "store", options: .atomic)

        self.jobStoreArray = operations
    }

    mutating func removeFirst() {
        if(self.jobStoreArray.count > 0) {
            self.jobStoreArray.removeFirst()

            let jsonEncoder = JSONEncoder()
            guard let data = try? jsonEncoder.encode(jobStoreArray) else {
                return
            }
            try! (data as NSData).write(toFile: "store", options: .atomic)
        }
    }
}
