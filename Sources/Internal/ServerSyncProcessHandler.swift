import Foundation

// Needs to be Codable
public enum ServerSyncJob {
    case StartJob(token: String)
    case RefreshTokenJob(newToken: String)
    case SubscribeJob(interest: String)
    case UnsubscribeJob(interest: String)
    case SetSubscriptions(interests: [String])
    case ApplicationStartJob(metadata: Metadata)
    case SetUserIdJob(userId: String)
    case StopJob
}

public class ServerSyncProcessHandler {
    private let queue: DispatchQueue
    private let networkService: NetworkService

    init(instanceId: String) {
        self.queue = DispatchQueue(label: "queue")
        let session = URLSession(configuration: .ephemeral)
        self.networkService = NetworkService(session: session, instanceId: instanceId)
    }

    public func sendMessage(serverSyncJob: ServerSyncJob) {
        self.queue.async {
            self.handleMessage(serverSyncJob: serverSyncJob)
        }
    }

    private func processStartJob(token: String) {
        // Register device with Error
        let result = self.networkService.register(deviceToken: token, metadata: Metadata.get(), retryStrategy: WithInfiniteExpBackoff())

        switch result {
        case .error(let error):
            print("[PushNotifications]: Unrecoverable error when registering device with Pusher Beams (Reason - \(error.getErrorMessage()))")
            print("[PushNotifications]: SDK will not start.")
            return
        case .value(let deviceId):
            var outstandingJobs: [ServerSyncJob]
            
        }
    }

    private func handleMessage(serverSyncJob: ServerSyncJob) {
        switch serverSyncJob {
        case .StartJob(let token):
            processStartJob(token: token)
        default:
            print("Not implemented")
        }
    }
}
