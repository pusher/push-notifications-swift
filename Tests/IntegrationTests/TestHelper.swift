import Foundation
@testable import PushNotifications

struct TestHelper {

    func removeSyncjobStore() {
        let url = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let filePath = url.appendingPathComponent("syncJobStore")
        try? FileManager.default.removeItem(atPath:  filePath.relativePath)
    }
    
    func setUpDeviceId(instanceId: String) {
        if let deviceId = InstanceDeviceStateStore(nil).getDeviceId() {
            TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
        }
    }
    
    func tearDownDeviceId(instanceId: String) {
        if let deviceId = InstanceDeviceStateStore(nil).getDeviceId() {
           TestAPIClientHelper().deleteDevice(instanceId: instanceId, deviceId: deviceId)
       }
    }
    
}
