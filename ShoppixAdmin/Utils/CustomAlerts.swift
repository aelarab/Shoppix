
import Foundation
import UIKit

class CustomAlerts{
    
    static func presentAlert(vc:UIViewController, title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: Constants.ok, style: .default)
        alert.addAction(action)
        vc.present(alert , animated: true)
    }
    
}
