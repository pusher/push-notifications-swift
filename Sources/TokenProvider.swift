import Foundation

/**
 TokenProviderError.

 *Values*

 `error` Token provider error message.
 */
public enum TokenProviderError: Error {
    /**
     Token provider error.

     - Parameter: Token provider error message.
     */
    case error(String)
}

/**
 TokenProvider protocol.

 Conform to the TokenProvider protocol in order to generate the token for the user that you want to authenticate.
 */
@objc public protocol TokenProvider {
    /**
     Method `fetchToken` will return the token on success or error on failure.

     - Parameter userId: Id of the user that you want to generate the token for.
     - Parameter completion: The block to execute when operation succeeds or fails.

     - Precondition: `userId` should not be nil.
     */
    func fetchToken(userId: String, completionHandler completion: @escaping (String, Error?) -> Void)
}
