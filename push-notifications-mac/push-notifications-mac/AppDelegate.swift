import Cocoa
import PushNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let pushNotifications = PushNotifications.shared
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.pushNotifications.register(instanceId: "1c3f32ef-b5f5-4762-95d5-e05f29a01476")
    }
    
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken) {
            self.pushNotifications.subscribe(interest: "hello")
        }
    }
    
    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
}
