import Foundation

/**
 Errors thrown by PushNotifications.

 *Values*

 `userAlreadyExists` User already exists.
 `beamsTokenProviderNotSetException` Beams Token Provider not set.
 */
public enum UserValidationtError: Error {
     // User already exists.
    case userAlreadyExists
    // Beams Token Provider not set.
    case beamsTokenProviderNotSetException
}
