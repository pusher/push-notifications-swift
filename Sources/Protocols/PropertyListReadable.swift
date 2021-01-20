import Foundation

protocol PropertyListReadable {
    func propertyListRepresentation() -> [String: Any]
    init(propertyListRepresentation: [String: Any])
}
