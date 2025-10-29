
import Foundation
import UIKit

extension UIViewController {
    func showAlert(Title: String, Message: String) {
        let alert = UIAlertController(title: Title, message: Message, preferredStyle: UIAlertController.Style.actionSheet)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }

}

extension UIView {
    func giveShadowAndRadius(scale: Bool = true, shadowRadius:Int, cornerRadius:Int) {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = .zero
        layer.shadowRadius = CGFloat(integerLiteral: shadowRadius)
        layer.shouldRasterize = true
        layer.cornerRadius = CGFloat(integerLiteral: cornerRadius)
    }
    
    func showToastMessage(message: String, color: UIColor) {
        let toastLabel = UILabel()
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = color
        toastLabel.textColor = .black
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 40
        toastLabel.clipsToBounds = true
        toastLabel.text = message
        self.addSubview(toastLabel)
        
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            toastLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            toastLabel.widthAnchor.constraint(equalToConstant: 100),
            toastLabel.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        UIView.animate(withDuration: 3.0, delay: 1.0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }
}

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }
}
extension Formatter {
    static let iso8601 = ISO8601DateFormatter([.withInternetDateTime])
}
extension Date {
    var iso8601: String { return Formatter.iso8601.string(from: self) }
}
