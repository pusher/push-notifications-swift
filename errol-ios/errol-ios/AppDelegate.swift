import UIKit
import Errol

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let errol = Errol.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.errol.register(instanceId: "c0c65938-5dcf-4e8b-9206-f72a8d86684b")

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.errol.registerDeviceToken(deviceToken)
    }
}
