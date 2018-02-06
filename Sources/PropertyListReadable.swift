import Foundation

protocol PropertyListReadable {
    func propertyListRepresentation() -> Dictionary<String, Any>
    init(propertyListRepresentation: Dictionary<String, Any>)
}
