import Foundation

struct PersistenceService: InterestPersistable {

    let service: UserDefaults
    private let prefix = "com.pusher.sdk.interests"

    func persist(interest: String) -> Bool {
        guard !self.interestExists(interest: interest) else { return false }

        service.set(interest, forKey: self.prefixInterest(interest))
        return true
    }

    func persist(interests: Array<String>) {
        self.removeAll()
        for interest in interests {
            _ = self.persist(interest: interest)
        }
    }

    func remove(interest: String) -> Bool {
        guard self.interestExists(interest: interest) else { return false }

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

    func getSubscriptions() -> Array<String>? {
        var interests: [String] = []
        for element in service.dictionaryRepresentation() {
            if element.key.hasPrefix(prefix) {
                interests.append(String(describing: element.value))
            }
        }

        return interests
    }

    private func interestExists(interest: String) -> Bool {
        guard let _ = service.object(forKey: self.prefixInterest(interest)) else { return false }

        return true
    }

    private func prefixInterest(_ interest: String) -> String {
        return "\(prefix):\(interest)"
    }
}
