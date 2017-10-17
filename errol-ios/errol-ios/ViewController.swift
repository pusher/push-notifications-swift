import UIKit
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let session = URLSession.shared
        let url = URL.init(string: "https://errol-staging.herokuapp.com/device_api/v1/instances/c0c65938-5dcf-4e8b-9206-f72a8d86684b/devices/apns")!
        let networkService = NetworkService.init(url: url, session: session)

        networkService.register(deviceToken: "dddd")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
