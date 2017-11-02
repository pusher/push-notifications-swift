import UIKit
import Errol

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let errol = Errol.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.errol.register(instanceId: "a13f9ccc-02d2-4a46-96a2-9874fe901a96")

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.errol.registerDeviceToken(deviceToken) {
            self.errol.getInterests {
                print("...")
            }
        }
    }
}
