import Foundation

internal class ServerSyncEventHandler {
    
    static let serverSyncEventHandlersQueue = DispatchQueue(label: "com.pusher.beams.serverSyncEventHandlersQueue")
    static var serverSyncEventHandlers = [String: ServerSyncEventHandler]()
    
    static func obtain(instanceId: String) -> ServerSyncEventHandler {
        return serverSyncEventHandlersQueue.sync {
            if let handler = self.serverSyncEventHandlers[instanceId] {
                return handler
            } else {
                let handler = ServerSyncEventHandler()
                self.serverSyncEventHandlers[instanceId] = handler
                return handler
            }
        }
    }
    
    // used only for testing purposes
    internal static func destroy(instanceId: String) {
        _ = serverSyncEventHandlersQueue.sync {
            self.serverSyncEventHandlers.removeValue(forKey: instanceId)
        }
    }
    
    internal var userIdCallbacks = Dictionary<String, [(Error?) -> Void]>()
    internal var stopCallbacks = [() -> Void]()
    
    private var interestsChangedDelegates = [() -> InterestsChangedDelegate?]()

    func handleEvent(event: ServerSyncEvent) {
        DispatchQueue.main.async {
            switch event {
            case .InterestsChangedEvent(let interests):
                self.interestsChangedDelegates.forEach({ delegate in
                    if let d = delegate() {
                        d.interestsSetOnDeviceDidChange(interests: interests)
                    }
                })
                
            case .UserIdSetEvent(let userId, let error):
                if !(self.userIdCallbacks[userId]?.isEmpty ?? true) {
                    if let completion = self.userIdCallbacks[userId]?.removeFirst() {
                        completion(error)
                    }
                }
            case .StopEvent:
                if !(self.stopCallbacks.isEmpty) {
                    let completion = self.stopCallbacks.removeFirst()
                    completion()
                }
            }
        }
    }
    
    func registerInterestsChangedDelegate(_ interestsChangedDelegate: @escaping () -> InterestsChangedDelegate?) {
        self.interestsChangedDelegates.append(interestsChangedDelegate)
    }
    
}
