import Foundation

/**
 Errors thrown by PushNotifications.

 *Values*

 `invalidName` The interest name is invalid.

 `invalidNames` The interest names are invalid.
 */
public enum InterestValidationError: Error {
    case invalidName(String)
    case invalidNames(Array<String>)
}
