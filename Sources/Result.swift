import Foundation

public enum Result<Value, Error> {
    case value(Value)
    case error(Error)
}
