import Foundation

public class InstanceDeviceStateStore {
    static let queue = DispatchQueue(label: "deviceStateStoreQueue")
    let service: UserDefaults
    let instanceId: String?

    init(_ instanceId: String?) {
        self.instanceId = instanceId
        self.service = UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName(instanceId: nil))!
    }
    
    public static func synchronize<T>(f: () -> T) -> T {
        var result: T?
        InstanceDeviceStateStore.queue.sync {
            result = f()
        }
        return result!
    }
    
    private func removeFromPersistanceStore(prefix: String) {
        for element in service.dictionaryRepresentation() {
            if element.key.hasPrefix(prefix) {
                service.removeObject(forKey: element.key)
            }
        }
    }
    
    // MARK: Instance Id
    func persistInstanceId(_ instanceId: String) {
        self.service.set(instanceId, forKey: PersistenceConstants.UserDefaults.instanceId)
    }

    func getInstanceId() -> String? {
        return self.service.string(forKey: PersistenceConstants.UserDefaults.instanceId)
    }
    
    // MARK: Interest
    func persistInterest(_ interest: String) -> Bool {
        guard !self.interestExists(interest: interest) else {
            return false
        }
        
        service.set(interest, forKey: self.prefixInterest(interest))
        return true
    }
    
    func removeInterest(interest: String) -> Bool {
        guard self.interestExists(interest: interest) else {
            return false
        }
        
        service.removeObject(forKey: self.prefixInterest(interest))
        return true
    }
    
    private func interestExists(interest: String) -> Bool {
        return service.object(forKey: self.prefixInterest(interest)) != nil
    }
    
    private func prefixInterest(_ interest: String) -> String {
        return "\(PersistenceConstants.PersistenceService.prefix):\(interest)"
    }
    
    // MARK: Interests
    func getInterests() -> [String]? {
        return service.dictionaryRepresentation().filter { $0.key.hasPrefix(PersistenceConstants.PersistenceService.prefix) }.map { String(describing: ($0.value)) }
    }
    
    func persistInterests(_ interests: [String]) -> Bool {
        guard
            let persistedInterests = self.getInterests(),
            persistedInterests.sorted().elementsEqual(interests.sorted())
            else {
                self.removeAllInterests()
                for interest in interests {
                    _ = self.persistInterest(interest)
                }
                
                return true
        }
        
        return false
    }
    
    func removeAllInterests() {
        self.removeFromPersistanceStore(prefix: PersistenceConstants.PersistenceService.prefix)
    }
    
    // MARK: User Id
    func setUserId(userId: String) -> Bool {
        guard !self.userIdExists(userId: userId) else {
            return false
        }
        
        service.set(userId, forKey: PersistenceConstants.PersistenceService.userId)
        return true
    }
    
    func getUserId() -> String? {
        return service.object(forKey: PersistenceConstants.PersistenceService.userId) as? String
    }
    
    func removeUserId() {
        service.removeObject(forKey: PersistenceConstants.PersistenceService.userId)
    }
    
    private func userIdExists(userId: String) -> Bool {
        return service.object(forKey: PersistenceConstants.PersistenceService.userId) != nil
    }
    
    
    // MARK: Server Confirmed Interests Hash
    
    func persistServerConfirmedInterestsHash(_ hash: String) {
        service.set(hash, forKey: PersistenceConstants.PersistenceService.hashKey)
    }
    
    func getServerConfirmedInterestsHash() -> String {
        return service.value(forKey: PersistenceConstants.PersistenceService.hashKey) as? String ?? ""
    }
    
    
    
    // MARK: Start Job Has Been Enqueued
    func setStartJobHasBeenEnqueued(flag: Bool) {
        service.set(flag, forKey: PersistenceConstants.PushNotificationsInstancePersistence.startJob)
    }
    
    func getStartJobHasBeenEnqueued() -> Bool {
        return service.object(forKey: PersistenceConstants.PushNotificationsInstancePersistence.startJob) as? Bool ?? false
    }
    
    func removeStartJobHasBeenEnqueued() {
        service.removeObject(forKey: PersistenceConstants.PushNotificationsInstancePersistence.startJob)
    }
    
    // MARK: User Id Previously Called
    func setUserIdHasBeenCalledWith(userId: String) {
        service.set(userId, forKey: PersistenceConstants.PushNotificationsInstancePersistence.userId)
    }
    
    func getUserIdHasBeenCalledWith() -> String? {
        return service.object(forKey: PersistenceConstants.PushNotificationsInstancePersistence.userId) as? String
    }
    
    func removeUserIdHasBeenCalledWith() {
        service.removeObject(forKey: PersistenceConstants.PushNotificationsInstancePersistence.userId)
    }
    
    // MARK: Device
    func persistDeviceId(_ deviceId: String) {
        service.set(deviceId, forKey: PersistenceConstants.UserDefaults.deviceId)
    }
    
    func deleteDeviceId() {
        service.removeObject(forKey: PersistenceConstants.UserDefaults.deviceId)
    }
    
    func deviceIdAlreadyPresent() -> Bool {
        return self.getDeviceId() != nil
    }
    
    func getDeviceId() -> String? {
        return service.string(forKey: PersistenceConstants.UserDefaults.deviceId)
    }
    
    // MARK: APNS Token
    func persistAPNsToken(token: String) {
        service.set(token, forKey: PersistenceConstants.UserDefaults.deviceAPNsToken)
    }
    
    func deleteAPNsToken() {
        service.removeObject(forKey: PersistenceConstants.UserDefaults.deviceAPNsToken)
    }
    
    func getAPNsToken() -> String? {
        return service.string(forKey: PersistenceConstants.UserDefaults.deviceAPNsToken)
    }
    
    // MARK: Metadata
    
    func getCurrentMetadata() -> Metadata {
        let sdkVersion = SDK.version
        let systemVersion = SystemVersion.version

        #if os(iOS)
        return Metadata(sdkVersion: sdkVersion, iosVersion: systemVersion, macosVersion: nil)
        #elseif os(OSX)
        return Metadata(sdkVersion: sdkVersion, iosVersion: nil, macosVersion: systemVersion)
        #endif
    }

    func saveMetadata(metadata: Metadata) {
        service.set(metadata.sdkVersion, forKey: PersistenceConstants.UserDefaults.metadataSDKVersion)
        service.set(metadata.iosVersion, forKey: PersistenceConstants.UserDefaults.metadataiOSVersion)
        service.set(metadata.macosVersion, forKey: PersistenceConstants.UserDefaults.metadataMacOSVersion)
    }

    func loadMetadata() -> Metadata {
        return Metadata(
            sdkVersion: service.string(forKey: PersistenceConstants.UserDefaults.metadataSDKVersion),
            iosVersion: service.string(forKey: PersistenceConstants.UserDefaults.metadataiOSVersion),
            macosVersion: service.string(forKey: PersistenceConstants.UserDefaults.metadataMacOSVersion)
        )
    }

    func deleteMetadata() {
        service.removeObject(forKey: PersistenceConstants.UserDefaults.metadataSDKVersion)
        service.removeObject(forKey: PersistenceConstants.UserDefaults.metadataiOSVersion)
        service.removeObject(forKey: PersistenceConstants.UserDefaults.metadataMacOSVersion)
    }

    // MARK: Deletion
    func clear() {
        self.removeFromPersistanceStore(prefix: PersistenceConstants.PersistenceService.globalScopeId)
    }

}
