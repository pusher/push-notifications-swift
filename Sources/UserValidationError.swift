import Foundation

/**
 Errors thrown by PushNotifications.

 *Values*

 `userExists` User already exists.
 `beamsTokenProviderException` Beams Token Provider not set.
 */
public enum UserValidationtError: Error {
     // User already exists.
    case userExists
    // Beams Token Provider not set.
    case beamsTokenProviderException
}
