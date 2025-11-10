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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            designButton(button: sendButtonOutlet)
            designTextField(text: forgetTextField)
            
        }

    }
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
                guard checkInternetConnection() else {
                    self.andicator.stopAnimating()
                    sender.isEnabled = true
                    return
                }
                guard let email = forgetTextField.text, !email.isEmpty else {
                    self.showAlert(title: "x", message: "Please enter your email.")
                    sender.isEnabled = true
                    andicator.startAnimating()
                       return
                   }
                andicator.startAnimating()
                  
                FirebaseAuth.Auth.auth().sendPasswordReset(withEmail: email) { error in
                    self.andicator.stopAnimating()
                    sender.isEnabled = true
                        if let error = error {
                            self.showAlert(title: "Error", message: error.localizedDescription)
                        } else {
                  let alert = UIAlertController(title: " Success",
                                                          message: "If this email exists, a password reset link has been sent.",
                                                          preferredStyle: .alert)
                            self.present(alert, animated: true)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                alert.dismiss(animated: true) {
                                    self.dismiss(animated: true)
                                     self.forgetTextField.text = ""
                                    }
                                }
                        }
                    }
    }

    
}
