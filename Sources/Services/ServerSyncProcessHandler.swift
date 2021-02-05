import Foundation

class ServerSyncProcessHandler {
    private static let serverSyncHandlersQueue = DispatchQueue(label: "com.pusher.beams.serverSyncHandlersQueue")
    private static var serverSyncHandlers = [String: ServerSyncProcessHandler]()
    static func obtain(instanceId: String, getTokenProvider: @escaping () -> TokenProvider?, handleServerSyncEvent: @escaping (ServerSyncEvent) -> Void) -> ServerSyncProcessHandler {
        return serverSyncHandlersQueue.sync {
            if let handler = self.serverSyncHandlers[instanceId] {
                return handler
            } else {
                let handler = ServerSyncProcessHandler(instanceId: instanceId, getTokenProvider: getTokenProvider, handleServerSyncEvent: handleServerSyncEvent)
                self.serverSyncHandlers[instanceId] = handler
                return handler
            }
        }
    }

    static func obtain(instanceId: String) -> ServerSyncProcessHandler? {
        return serverSyncHandlersQueue.sync {
            return self.serverSyncHandlers[instanceId]
        }
    }

    // used only for testing purposes
    static func destroy(instanceId: String) {
        _ = serverSyncHandlersQueue.sync {
            self.serverSyncHandlers.removeValue(forKey: instanceId)
        }
    }

    private let instanceId: String
    private let sendMessageQueue: DispatchQueue
    private let handleMessageQueue: DispatchQueue
    private let networkService: NetworkService
    private let getTokenProvider: () -> TokenProvider?
    private let handleServerSyncEvent: (ServerSyncEvent) -> Void
    public var jobQueue: ServerSyncJobStore
    private let deviceStateStore: InstanceDeviceStateStore

    init(instanceId: String, getTokenProvider: @escaping () -> TokenProvider?, handleServerSyncEvent: @escaping (ServerSyncEvent) -> Void) {
        self.instanceId = instanceId
        self.deviceStateStore = InstanceDeviceStateStore(instanceId)
        self.getTokenProvider = getTokenProvider
        self.handleServerSyncEvent = handleServerSyncEvent
        self.sendMessageQueue = DispatchQueue(label: "com.pusher.beams.sendMessageQueue")
        self.handleMessageQueue = DispatchQueue(label: "com.pusher.beams.handleMessageQueue")
        let session = URLSession(configuration: .ephemeral)
        self.networkService = NetworkService(session: session)
        self.jobQueue = ServerSyncJobStore(instanceId: self.instanceId)

        self.jobQueue.toList().forEach { job in
            switch job {
            case .setUserIdJob:
                // Skipping it. If the user is still supposed to logged in, then
                // there should be another setUserIdJob being enqueued upon launch
                return

            default:
                self.handleMessageQueue.async {
                    self.handleMessage(serverSyncJob: job)
                }
            }
        }
    }

    func sendMessage(serverSyncJob: ServerSyncJob) {
        self.sendMessageQueue.async {
            self.jobQueue.append(serverSyncJob)

            self.handleMessageQueue.async {
                self.handleMessage(serverSyncJob: serverSyncJob)
            }
        }
    }

    private func hasStarted() -> Bool {
        return InstanceDeviceStateStore.synchronize {
            return self.deviceStateStore.deviceIdAlreadyPresent()
        }
    }

    private func processStartJob(instanceId: String, token: String) {
        // Register device with Error
        let result = self.networkService.register(instanceId: instanceId, deviceToken: token, metadata: .current, retryStrategy: WithInfiniteExpBackoff())

        switch result {
        case .failure(let error):
            print("[PushNotifications]: Unrecoverable error when registering device with Pusher Beams (Reason - \(error.debugDescription))")
            print("[PushNotifications]: SDK will not start.")
            return

        case .success(let device):
            var outstandingJobs: [ServerSyncJob] = []
            InstanceDeviceStateStore.synchronize {
                // Replay sub/unsub/setsub operations in job queue over initial interest set
                var interestsSet = device.initialInterestSet ?? Set<String>()

                for job in jobQueue.toList() {
                    switch job {
                    case .startJob:
                        break

                    case .subscribeJob(let interest, _):
                        interestsSet.insert(interest)

                    case .unsubscribeJob(let interest, _):
                        interestsSet.remove(interest)

                    case .setSubscriptions(let interests, _):
                        interestsSet = Set(interests)

                    case .stopJob:
                        outstandingJobs.removeAll()
                        // Any subscriptions changes done at this point are just discarded,
                        // and we need to assume the initial interest set as the starting point again
                        interestsSet = device.initialInterestSet ?? Set<String>()

                    case .setUserIdJob:
                        outstandingJobs.append(job)

                    case .applicationStartJob:
                        // ignoring it as we are already going to sync the state anyway
                        continue

                    case .refreshTokenJob:
                        outstandingJobs.append(job)

                    case .reportEventJob:
                        // If SDK hasn't started yet we couldn't have receive any remote notifications
                        continue
                    }
                }

                let localInterestsWillChange = Set(self.deviceStateStore.getInterests() ?? []) != interestsSet
                if localInterestsWillChange {
                    _ = self.deviceStateStore.persistInterests(Array(interestsSet))
                    self.handleServerSyncEvent(.interestsChangedEvent(interests: Array(interestsSet)))
                }

                self.deviceStateStore.persistAPNsToken(token: token)
                self.deviceStateStore.persistDeviceId(device.id)
            }

            let localInterests = self.deviceStateStore.getInterests() ?? []
            let remoteInterestsWillChange = Set(localInterests) != device.initialInterestSet ?? Set()
            if remoteInterestsWillChange {
                // We don't care about the result at this point.
                _ = self.networkService.setSubscriptions(instanceId: self.instanceId, deviceId: device.id, interests: localInterests, retryStrategy: WithInfiniteExpBackoff())
            }

            for job in outstandingJobs {
                processJob(job)
            }
        }
    }

    private func processStopJob() {
        _ = self.networkService.deleteDevice(instanceId: self.instanceId, deviceId: self.deviceStateStore.getDeviceId()!, retryStrategy: WithInfiniteExpBackoff())
//        Instance.delete()
        self.deviceStateStore.deleteDeviceId()
        self.deviceStateStore.deleteAPNsToken()
        self.deviceStateStore.removeMetadata()
        self.deviceStateStore.persistServerConfirmedInterestsHash("")
        self.deviceStateStore.removeUserId()
        self.handleServerSyncEvent(.stopEvent)
    }

    private func processApplicationStartJob(metadata: Metadata) {
        let localMetadata = self.deviceStateStore.getMetadata()
        if metadata != localMetadata {
            let result = self.networkService.syncMetadata(instanceId: self.instanceId, deviceId: self.deviceStateStore.getDeviceId()!, metadata: metadata, retryStrategy: JustDont())
            if case .success = result {
                self.deviceStateStore.persistMetadata(metadata: metadata)
            }
        }

        let localInterests = self.deviceStateStore.getInterests() ?? []
        let localInterestsHash = localInterests.calculateMD5Hash()

        if localInterestsHash != self.deviceStateStore.getServerConfirmedInterestsHash() {
            let result = self.networkService.setSubscriptions(instanceId: self.instanceId, deviceId: self.deviceStateStore.getDeviceId()!, interests: localInterests, retryStrategy: JustDont())
            if case .success = result {
                self.deviceStateStore.persistServerConfirmedInterestsHash(localInterestsHash)
            }
        }
    }

    private func processJob(_ job: ServerSyncJob) {
        let result: Result<Void, PushNotificationsAPIError> = {
            switch job {
            case .subscribeJob(_, localInterestsChanged: false), .unsubscribeJob(_, localInterestsChanged: false), .setSubscriptions(_, localInterestsChanged: false):
                return .success(()) // if local interests haven't changed, then we don't need to sync with server
            case .subscribeJob(let interest, localInterestsChanged: true):
                return self.networkService.subscribe(instanceId: self.instanceId, deviceId: self.deviceStateStore.getDeviceId()!, interest: interest, retryStrategy: WithInfiniteExpBackoff())

            case .unsubscribeJob(let interest, localInterestsChanged: true):
                return self.networkService.unsubscribe(instanceId: self.instanceId, deviceId: self.deviceStateStore.getDeviceId()!, interest: interest, retryStrategy: WithInfiniteExpBackoff())

            case .setSubscriptions(let interests, localInterestsChanged: true):
                return self.networkService.setSubscriptions(instanceId: self.instanceId, deviceId: self.deviceStateStore.getDeviceId()!, interests: interests, retryStrategy: WithInfiniteExpBackoff())

            case .reportEventJob(let eventType):
                return self.networkService.track(instanceId: eventType.getInstanceId(), deviceId: self.deviceStateStore.getDeviceId()!, eventType: eventType, retryStrategy: WithInfiniteExpBackoff())

            case .applicationStartJob(let metadata):
                processApplicationStartJob(metadata: metadata)
                return .success(()) // this was always a best effort operation
            case .setUserIdJob(let userId):
                processSetUserIdJob(userId: userId)
                return .success(()) // errors were already handled at this point
            case .startJob, .stopJob:
                return .success(()) // already handled in `handleMessage`
            case .refreshTokenJob:
                // TODO: Implement refresh token
                return .success(())
            }
        }()

        switch result {
        case .success:
            return

        case .failure(.deviceNotFound):
            if recreateDevice(token: self.deviceStateStore.getAPNsToken()!) {
                processJob(job)
            } else {
                print("[PushNotifications]: Not retrying, skipping job: \(job).")
            }

        case .failure(let error):
            // not really recoverable, so log it here and also monitor 400s closely on our backend
            // (this really shouldn't happen)
            print("[PushNotifications]: Fail to make a valid request to the server for job \(job), skipping it. Error: \(error)")
            return
        }
    }

    private func recreateDevice(token: String) -> Bool {
        // Register device with Error
        let result = self.networkService.register(instanceId: self.instanceId, deviceToken: token, metadata: .current, retryStrategy: WithInfiniteExpBackoff())

        switch result {
        case .failure(let error):
            print("[PushNotifications]: Unrecoverable error when registering device with Pusher Beams (Reason - \(error.debugDescription))")
            return false

        case .success(let device):
            let localIntersets: [String] = InstanceDeviceStateStore.synchronize {
                self.deviceStateStore.persistDeviceId(device.id)
                self.deviceStateStore.persistAPNsToken(token: token)
                return self.deviceStateStore.getInterests() ?? []
            }

            if !localIntersets.isEmpty {
                _ = self.networkService.setSubscriptions(instanceId: self.instanceId, deviceId: device.id, interests: localIntersets, retryStrategy: WithInfiniteExpBackoff())
            }

            if let userId = self.deviceStateStore.getUserId() {
                let tokenProvider = self.getTokenProvider()
                if tokenProvider == nil {
                    // Any failures during this process are equivalent to de-authing the user e.g. persistUserId(null)
                    // If the user session is indeed over, there should be a Stop in the backlog eventually
                    // If the user session is still valid, there should be a setUserId in the backlog

                    print("[PushNotifications]: Warning - Failed to set the user id due token provider not being present")
                    self.deviceStateStore.removeUserId()
                } else {
                    let semaphore = DispatchSemaphore(value: 0)
                    do {
                        try tokenProvider!.fetchToken(userId: userId, completionHandler: { jwt, error in
                            if error != nil {
                                print("[PushNotifications]: Warning - Unexpected customer error: \(error!.localizedDescription)")
                                self.deviceStateStore.removeUserId()
                                semaphore.signal()
                                return
                            }

                            let result = self.networkService.setUserId(instanceId: self.instanceId, deviceId: self.deviceStateStore.getDeviceId()!, token: jwt, retryStrategy: WithInfiniteExpBackoff())

                            switch result {
                            case .success:
                                _ = self.deviceStateStore.persistUserId(userId: userId)

                            case .failure(let error):
                                print("[PushNotifications]: Warning - Unexpected error: \(error.debugDescription)")
                                self.deviceStateStore.removeUserId()
                                semaphore.signal()
                                return
                            }

                            semaphore.signal()
                        })
                        semaphore.wait()
                    } catch let error {
                        print("[PushNotifications]: Warning - Unexpected error: \(error.localizedDescription)")
                        self.deviceStateStore.removeUserId()
                    }
                }
            }

            return true
        }
    }

    func processSetUserIdJob(userId: String) {
        guard let tokenProvider = self.getTokenProvider() else {
            let error = TokenProviderError.error("[PushNotifications] - Token provider missing")
            self.handleServerSyncEvent(.userIdSetEvent(userId: userId, error: error))
            return
        }

        let semaphore = DispatchSemaphore(value: 0)
        do {
            try tokenProvider.fetchToken(userId: userId, completionHandler: { jwt, error in
                if error != nil {
                    let error = TokenProviderError.error("[PushNotifications] - Error when fetching token: \(error!)")
                    self.handleServerSyncEvent(.userIdSetEvent(userId: userId, error: error))
                    semaphore.signal()
                    return
                }

                let result = self.networkService.setUserId(instanceId: self.instanceId, deviceId: self.deviceStateStore.getDeviceId()!, token: jwt, retryStrategy: WithInfiniteExpBackoff())

                switch result {
                case .success:
                    _ = self.deviceStateStore.persistUserId(userId: userId)
                    self.handleServerSyncEvent(.userIdSetEvent(userId: userId, error: nil))

                case .failure(let error):
                    let error = TokenProviderError.error("[PushNotifications] - Error when synchronising with server: \(error)")
                    self.handleServerSyncEvent(.userIdSetEvent(userId: userId, error: error))
                    semaphore.signal()
                    return
                }

                semaphore.signal()
            })
            semaphore.wait()
        } catch let error {
            let error = TokenProviderError.error("[PushNotifications] - Error when executing `fetchToken` method: \(error)")
            self.handleServerSyncEvent(.userIdSetEvent(userId: userId, error: error))
        }
    }

    func handleMessage(serverSyncJob: ServerSyncJob) {
        // If the SDK hasn't started yet we can't do anything, so skip
        var shouldSkip: Bool
        if case .startJob = serverSyncJob {
            shouldSkip = false
        } else {
            shouldSkip = !hasStarted()
        }

        if shouldSkip {
            return
        }

        switch serverSyncJob {
        case .startJob(let instanceId, let token):
            processStartJob(instanceId: instanceId, token: token)

            // Clear up the queue up to the StartJob.
            while !jobQueue.isEmpty {
                switch jobQueue.first! {
                case .startJob:
                    jobQueue.removeFirst()
                    return

                default:
                    jobQueue.removeFirst()
                }
            }

        case .stopJob:
            processStopJob()
            jobQueue.removeFirst()

        default:
            processJob(serverSyncJob)
            jobQueue.removeFirst()
        }
    }
}
