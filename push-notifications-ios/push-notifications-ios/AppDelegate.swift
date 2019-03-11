import UIKit
import PushNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let pushNotifications = PushNotifications.shared

    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let tokenProvider = BeamsTokenProvider(authURL: "YOUR-TOKEN-PROVIDER-URL") { () -> AuthData in
            let sessionToken = "SESSION-TOKEN"
            return AuthData(headers: ["Authorization": "Bearer \(sessionToken)"], queryParams: [:])
        }

        self.pushNotifications.start(instanceId: "YOUR_INSTANCE_ID") // Can be found here: https://dash.pusher.com
        self.pushNotifications.setUserId("Johnny Cash", tokenProvider: tokenProvider, completion: { (error) in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
        })

        self.pushNotifications.registerForRemoteNotifications()

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.pushNotifications.handleNotification(userInfo: userInfo)
        print(userInfo)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
}
