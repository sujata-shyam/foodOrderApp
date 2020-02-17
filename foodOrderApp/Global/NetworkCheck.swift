import Foundation
import Network
import UIKit

class NetworkCheck {
    
    let monitor : NWPathMonitor
    static let sharedInstance = NetworkCheck()
    
    init() {
        monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                //print("Connected")
                NotificationCenter.default.post(name: NSNotification.Name("gotInternetConnection"), object: nil)
            }
            else
            {
                DispatchQueue.main.async {
                    stopActivityIndicator(vc: (UIApplication.shared.keyWindow?.rootViewController!)!)
                    
                    let alertController =  UIAlertController(title: "", message: "No internet connection", preferredStyle: .alert)
                    
                    UIApplication.shared.keyWindow?.rootViewController!.present(alertController, animated: true) {
                        sleep(5)
                        alertController.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    func startMonitoring()
    {
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }
    
    func stopMonitoring()
    {
        monitor.cancel()
    }
}
