import Foundation

struct InterestsHash {

    func persist(_ hash: String) {
        UserDefaults(suiteName: "InterestsHash")?.set(hash, forKey: "interestsHash")
    }

    func serverConfirmedInterestsHash() -> String {
        return (UserDefaults(suiteName: "InterestsHash")?.value(forKey: "interestsHash") as? String) ?? ""
    }
}
