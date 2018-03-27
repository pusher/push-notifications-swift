import Foundation

enum NetworkResponse {
    case Success(data: Data)
    case Failure(data: Data)
}
