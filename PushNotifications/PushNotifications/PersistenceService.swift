import Foundation

struct PersistenceService: InterestPersistable {

    let service: UserDefaults

    func persist(interest: String) -> Bool {
        if self.interestExists(interest: interest) {
            return false
        }
        else {
            service.set(interest, forKey: interest)
            return true
        }
    }

    func persist(interests: Array<String>) -> Bool {
        if self.interestsExists(interests: interests) {
            return false
        }
        else {
            service.set(interests, forKey: "subscriptions")
            return true
        }
    }

    func remove(interest: String) -> Bool {
        if self.interestExists(interest: interest) {
            service.removeObject(forKey: interest)
            return true
        }

        return false
    }

    func removeAll() {
        service.removeObject(forKey: "subscriptions")
    }

    func getSubscriptions() -> Array<String> {
        return service.array(forKey: "subscriptions") as! Array<String>
    }

    private func interestExists(interest: String) -> Bool {
        guard let _ = service.object(forKey: interest) else { return false }

        return true
    }

    private func interestsExists(interests: Array<String>) -> Bool {
        guard let localInterests = service.array(forKey: "subscriptions") else { return false }

        if interests.containsSameElements(as: localInterests as! Array<String>) {
            return true
        }
        else {
            return false
        }
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
