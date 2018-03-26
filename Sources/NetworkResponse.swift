import Foundation

enum NetworkResponse {
    case Success(data: Data, response: HTTPURLResponse)
    case Failure(data: Data, response: HTTPURLResponse)
}
