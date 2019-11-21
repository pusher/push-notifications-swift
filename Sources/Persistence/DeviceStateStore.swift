import Foundation

public class DeviceStateStore {
    static let queue = DispatchQueue(label: "deviceStateStoreQueue")
    let service: UserDefaults = UserDefaults(suiteName: PersistenceConstants.UserDefaults.suiteName)!
    
    public static func synchronize<T>(f: () -> T) -> T {
        var result: T?
        DeviceStateStore.queue.sync {
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
    
    // MARK: Deletion
    func clear() {
        self.removeFromPersistanceStore(prefix: PersistenceConstants.PersistenceService.globalScopeId)
    }

}
