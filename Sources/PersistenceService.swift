import Foundation

struct PersistenceService: InterestPersistable {

    let service: UserDefaults
    private let prefix = Constants.PersistanceService.prefix

    func persist(interest: String) -> Bool {
        guard !self.interestExists(interest: interest) else {
            return false
        }

        service.set(interest, forKey: self.prefixInterest(interest))
        return true
    }

    func persist(interests: [String]) -> Bool {
        guard
            let persistedInterests = self.getSubscriptions(),
            persistedInterests.sorted().elementsEqual(interests.sorted())
        else {
            self.removeAll()
            for interest in interests {
                _ = self.persist(interest: interest)
            }

            return true
        }

        return false
    }

    func remove(interest: String) -> Bool {
        guard self.interestExists(interest: interest) else {
            return false
        }

        service.removeObject(forKey: self.prefixInterest(interest))
        return true
    }

    func removeAll() {
        for element in service.dictionaryRepresentation() {
            if element.key.hasPrefix(prefix) {
                service.removeObject(forKey: element.key)
            }
        }
    }

    func getSubscriptions() -> [String]? {
        return service.dictionaryRepresentation().filter { $0.key.hasPrefix(prefix) }.map { String(describing: ($0.value)) }
    }

    func persistServerConfirmedInterestsHash(_ hash: String) {
        service.set(hash, forKey: Constants.PersistanceService.hashKey)
    }

    func getServerConfirmedInterestsHash() -> String {
        return service.value(forKey: Constants.PersistanceService.hashKey) as? String ?? ""
    }

    private func interestExists(interest: String) -> Bool {
        return service.object(forKey: self.prefixInterest(interest)) != nil
    }

    private func prefixInterest(_ interest: String) -> String {
        return "\(prefix):\(interest)"
    }
}
