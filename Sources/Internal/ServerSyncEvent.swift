import Foundation

public enum ServerSyncEvent {
    case InterestsChangedEvent(interests: [String])
    case UserIdSetEvent(userId: String, error: Error?)
    case StopEvent
}
