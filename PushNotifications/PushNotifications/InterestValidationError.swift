import Foundation

public enum InterestValidationError: Error {
    case invalidName(String)
    case invalidNames(Array<String>)
}
