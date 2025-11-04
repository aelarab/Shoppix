//
//  LoginViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 26/10/2025.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var andicator: UIActivityIndicatorView!
    @IBOutlet weak var forgetLabel: UILabel!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var accLabel: UILabel!
    private let passwordTaoggleButton = UIButton(type: .custom)
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTaoggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        passwordTaoggleButton.tintColor = .gray
        passwordTaoggleButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        passwordTaoggleButton.addTarget(self, action: #selector(togglePasswordView(_:)), for: .touchUpInside)
        passwordTextField.rightView = passwordTaoggleButton
        passwordTextField.rightViewMode = .always
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .oneTimeCode
      
        loginButtonOutlet.setTitle("Login", for: .normal)
        designButton(button: loginButtonOutlet)
        designTextField(text:passwordTextField)
        designTextField(text:emailTextField)
        accLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addGestureForSignUp)))
        accLabel.textColor = UIColor(named: "mainColor")
        forgetLabel.textColor = UIColor(named: "mainColor")
        forgetLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addGestureForForget)))
        // Do any additional setup after loading the view.
    }

   @objc func addGestureForSignUp(){
       
       let signUpVC = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
       navigationController?.pushViewController(signUpVC, animated: true)
    }
    @objc func addGestureForForget(){
       
        let forgetVC = ForgetBassViewController(nibName: "ForgetBassViewController", bundle: nil)
       // navigationController?.pushViewController(forgetVC, animated: true)
        forgetVC.modalTransitionStyle = .crossDissolve
        self.present(forgetVC, animated: true, completion: nil)
     }
    
    @objc func togglePasswordView(_ sender: UIButton) {
        if sender == passwordTaoggleButton {
            passwordTextField.isSecureTextEntry.toggle()
            let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
            passwordTaoggleButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            designButton(button: loginButtonOutlet)
            designTextField(text:passwordTextField)
            designTextField(text:emailTextField)
            
        }

    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        guard checkInternetConnection() else { return }
        
        andicator.startAnimating()
        sender.isEnabled = false
        guard
              let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = passwordTextField.text,
              !email.isEmpty,!password.isEmpty else {
                  self.showAlert(title: "⚠️", message: "Please fill all fields")
                  sender.isEnabled = true
                  andicator.stopAnimating()
                  return
              }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

                        if let error = error {
                            self.showAlert(title: "❌", message: error.localizedDescription)
                            sender.isEnabled = true
                            self.andicator.stopAnimating()
                            return
                        }

                        guard let user = result?.user else {
                            sender.isEnabled = true
                            self.andicator.stopAnimating()
                            return }
            if user.isEmailVerified {
//                 self.showAlert(title: "✅ Success", message: "Welcome , \(email)!")
                UserDefaults.standard.set(user.uid, forKey: "userId")
                UserDefaults.standard.set(user.email, forKey: "email")
                print("id and email updated successfully and user logged in. ")
                let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
                self.navigationController?.setViewControllers([homeVC], animated: true)
               
            }  else {
                self.showAlert(title: "📧 Verify Email", message: "Please verify your email before logging in.")
                try? Auth.auth().signOut()
            }

            sender.isEnabled = true
            self.andicator.stopAnimating()
        }
    }
}
