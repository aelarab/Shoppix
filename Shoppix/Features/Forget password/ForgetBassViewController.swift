//
//  ForgetBassViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 27/10/2025.
//

import UIKit
import FirebaseAuth

class ForgetBassViewController: UIViewController {

   
    @IBOutlet weak var andicator: UIActivityIndicatorView!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    @IBOutlet weak var forgetTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButtonOutlet.setTitle("Send", for: .normal)
       designButton(button: sendButtonOutlet)
       designTextField(text: forgetTextField)
        
    }

//    func designButton(button:UIButton){
//        
//        button.setTitleColor(UIColor(named: "inverseLabelColor"), for: .normal)
//        button.backgroundColor = UIColor(named: "mainColor")
//        button.layer.cornerRadius = button.frame.height / 4
//       
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.systemGray4.cgColor
//     }
//    func designTextField(text :UITextField){
//        text.setPlaceholderColor(.systemGray)
//        text.layer.borderWidth = 1.0
//        text.layer.borderColor = UIColor(named: "mainColor")?.cgColor
//        text.layer.cornerRadius = text.frame.height / 4
//    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            designButton(button: sendButtonOutlet)
            designTextField(text: forgetTextField)
            
        }

    }
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard checkInternetConnection() else { return }
        guard let email = forgetTextField.text, !email.isEmpty else {
            self.showAlert(title: "⚠️", message: "Please enter your email.")
               return
           }
        andicator.startAnimating()
           sender.isEnabled = false
        FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: email) { error in
            self.andicator.stopAnimating()
            sender.isEnabled = true
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                } else {
                    self.showAlert(title: "Success", message: "If this email exists, a password reset link has been sent")
                }
            }
    }

    
}
