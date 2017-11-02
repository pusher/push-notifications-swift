import UIKit
import Errol

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let errol = Errol.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.errol.register(instanceId: "e3c54800-e058-4e75-9e20-424f7dddce30")

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.errol.registerDeviceToken(deviceToken) {
            self.errol.getInterests(completion: { (interests) in
                print(interests)
            })
        }
    }
}
