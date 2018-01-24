import Foundation

/**
 Errors thrown by PushNotifications.

 *Values*

 `invalidName` The interest name is invalid.

 `invalidNames` The interest names are invalid.
 */
public enum InterestValidationError: Error {
    /**
     Invalid interest name.

     - Parameter: interest
     */
    case invalidName(String)
    /**
     Invalid interest names.

     - Parameter: interests
     */
    case invalidNames(Array<String>)
}
