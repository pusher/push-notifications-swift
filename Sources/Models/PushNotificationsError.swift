import Foundation

/**
 Error thrown by PushNotifications.

 *Values*

 `error` General error message.
 */
public enum PushNotificationsError: Error {
    /**
     General error.

     - Parameter: error message.
     */
    case error(String)
}
