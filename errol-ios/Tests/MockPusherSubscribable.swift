import Foundation
@testable import errol_ios

struct MockPusherRegisterable: PusherRegisterable {
    func register(deviceToken: Data, completion: @escaping PusherRegisterable.CompletionHandler) {
        completion("ppns-876eeb5d-0dc8-4d74-9f59-b65412b2c742")
    }
}
