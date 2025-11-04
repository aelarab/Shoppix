//
//  Extension.swift
//  SHOPPIX
//
//  Created by adham ragap on 27/10/2025.
//

import Foundation
import UIKit
extension UIViewController {
    func designButton(button:UIButton){
        
        button.setTitleColor(UIColor(named: "inverseLabelColor"), for: .normal)
        button.backgroundColor = UIColor(named: "mainColor")
        button.layer.cornerRadius = button.frame.height / 4
       
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
     }
    func designTextField(text :UITextField){
        text.setPlaceholderColor(.systemGray)
        text.layer.borderWidth = 1.0
        text.layer.borderColor = UIColor(named: "mainColor")?.cgColor
        text.layer.cornerRadius = text.frame.height / 4
    }

    func clearUserDefaults() {
        let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "userId")
            defaults.removeObject(forKey: "email")
            defaults.synchronize()
            print("🧹 UserDefaults cleared")
    }
     func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func checkInternetConnection() -> Bool {
            if !CheckInternet().Connection() {
                showAlert(title: "⚠️ No Internet", message: "Please check your connection and try again.")
                return false
            }
            return true
        }
    

}

extension UITextField {
    func setPlaceholderColor(_ color: UIColor) {
        if let placeholder = placeholder {
            attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: color]
            )
        }
    }
}
