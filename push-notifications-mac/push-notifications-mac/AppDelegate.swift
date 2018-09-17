import Cocoa
import PushNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let pushNotifications = PushNotifications.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.pushNotifications.start(instanceId: "97c56dfe-58f5-408b-ab3a-158e51a860f2")
        self.pushNotifications.registerForRemoteNotifications()
        try? self.pushNotifications.subscribe(interest: "hello")
    }

    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken)
    }

    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String: Any]) {
        self.pushNotifications.handleNotification(userInfo: userInfo)
        print(userInfo)
    }

    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
}
