import Cocoa
import PushNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let pushNotifications = PushNotifications.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.pushNotifications.start(instanceId: "YOUR_INSTANCE_ID") // Can be found here: https://dash.pusher.com
        self.pushNotifications.registerForRemoteNotifications()
        try? self.pushNotifications.addDeviceInterest(interest: "debug-test")
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
