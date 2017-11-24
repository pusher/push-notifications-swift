import Foundation

struct PersistenceService: InterestPersistable {

    let service: UserDefaults

    func persist(interest: String) -> Bool {
        guard !self.interestExists(interest: interest) else { return false }

        service.set(interest, forKey: interest)
        return true
    }

    func persist(interests: Array<String>) -> Bool {
        guard !self.interestsExists(interests: interests) else { return false }

        service.set(interests, forKey: "subscriptions")
        return true
    }

    func remove(interest: String) -> Bool {
        guard self.interestExists(interest: interest) else { return false }

        service.removeObject(forKey: interest)
        return true
    }

    func removeAll() {
        service.removeObject(forKey: "subscriptions")
    }

    func getSubscriptions() -> Array<String>? {
        guard let subscriptions = service.array(forKey: "subscriptions") else { return nil }

        return subscriptions as? Array<String>
    }

    private func interestExists(interest: String) -> Bool {
        guard let _ = service.object(forKey: interest) else { return false }

        return true
    }

    private func interestsExists(interests: Array<String>) -> Bool {
        guard let localInterests = service.array(forKey: "subscriptions") as? Array<String> else { return false }

        return interests.containsSameElements(as: localInterests)
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
