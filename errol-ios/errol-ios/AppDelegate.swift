import UIKit
import Errol

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let errol = Errol.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.errol.register(instanceId: "8a070eaa-033f-46d6-bb90-f4c15acc47e1")

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.errol.registerDeviceToken(deviceToken)
    }
}
