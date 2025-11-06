//
//  SignUpViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 26/10/2025.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var andicator: UIActivityIndicatorView!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    private let passwordTaoggleButton = UIButton(type: .custom)
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTaoggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        passwordTaoggleButton.tintColor = .gray
        passwordTaoggleButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        passwordTaoggleButton.addTarget(self, action: #selector(togglePasswordView(_:)), for: .touchUpInside)
        PasswordTextField.rightView = passwordTaoggleButton
        PasswordTextField.rightViewMode = .always
        PasswordTextField.isSecureTextEntry = true
        PasswordTextField.textContentType = .oneTimeCode

        signUpButtonOutlet.setTitle("SignUp", for: .normal)
        designButton(button: signUpButtonOutlet)
        designTextField(text:PasswordTextField)
        designTextField(text:emailTextField)
        designTextField(text: lastNameTextField)
        designTextField(text: firstNameTextField)
    }
    @objc func togglePasswordView(_ sender: UIButton) {
        if sender == passwordTaoggleButton {
            PasswordTextField.isSecureTextEntry.toggle()
            let imageName = PasswordTextField.isSecureTextEntry ? "eye.slash" : "eye"
            passwordTaoggleButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
    }


            override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
                super.traitCollectionDidChange(previousTraitCollection)
    
                if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                    designButton(button: signUpButtonOutlet)
                    designTextField(text:PasswordTextField)
                    designTextField(text:emailTextField)
                    designTextField(text: lastNameTextField)
                    designTextField(text: firstNameTextField)
                }
    
            }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        guard checkInternetConnection() else { return }
        andicator.startAnimating()
        sender.isEnabled = false
        guard let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let password = PasswordTextField.text,
              !firstName.isEmpty,!lastName.isEmpty,!email.isEmpty,!password.isEmpty else {
                  self.showAlert(title: "⚠️", message: "Please fill all fields")
                  sender.isEnabled = true
                  andicator.stopAnimating()
                  return
              }
        if !isValidPassword(password) {
            self.showAlert(title: "Weak Password", message: "Password must contain at least one uppercase letter, one lowercase letter, one number, and be 6+ characters long.")
            sender.isEnabled = true
            andicator.stopAnimating()
                return
            }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                        self.showAlert(title: "❌", message: error.localizedDescription)
                sender.isEnabled = true
                self.andicator.stopAnimating()
                        return
            }else {
                guard let user = result?.user else { return }
                user.sendEmailVerification { error in
                    if let error = error {
                                    self.showAlert(title: "❌ Failed to send verification email", message: error.localizedDescription)
                        sender.isEnabled = true
                        self.andicator.stopAnimating()
                                    return
                    }else {
                        guard let user = result?.user else { return }
                        let uid = user.uid
                        let db = Firestore.firestore()
                        db.collection("users").document(uid).setData([
                            "firstName": firstName,
                            "lastName": lastName,
                            "email": email,
                            "createdAt": Timestamp(date: Date())
                        ]) { error in
                            if let error = error {
                                self.showAlert(title: "❌", message: "Failed to save data: \(error.localizedDescription)")
                                sender.isEnabled = true
                                self.andicator.stopAnimating()
                                return // <-- this return stops this closure
                            }
                        
                        let alert = UIAlertController(title: "✅ Verification Sent",
                                                      message: "A verification link has been sent to \(email). Please check your inbox.",
                                                      preferredStyle: .alert)
                        self.present(alert, animated: true)
                            NetworkManager().createShopifyCustomer(firstName: firstName, lastName: lastName, email: email) { shopifyId in
                                DispatchQueue.main.async {
                                    self.andicator.stopAnimating()
                                }
                               
                                if let shopifyId = shopifyId {
                                    db.collection("users").document(uid).updateData(["shopifyCustomerId": shopifyId])
                                    print("✅ Shopify user created with ID: \(shopifyId)")
                                } else {
                                    
                                print("❌ Failed to create Shopify customer")
                                }
                            }
                     //   print("User signed up successfully")
                        self.andicator.stopAnimating()
                        try? Auth.auth().signOut()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            alert.dismiss(animated: true) {
                                let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
                                self.navigationController?.setViewControllers([loginVC], animated: true)
                                self.firstNameTextField.text = ""
                                 self.lastNameTextField.text = ""
                                 self.emailTextField.text = ""
                                 self.PasswordTextField.text = ""
                                sender.isEnabled = true
                            }
                            }
                        }
                                 
                    }
                }
            }
        }
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    
}
