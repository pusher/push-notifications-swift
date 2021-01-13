import Foundation

enum ServerSyncEvent {
    case interestsChangedEvent(interests: [String])
    case userIdSetEvent(userId: String, error: Error?)
    case stopEvent
}
