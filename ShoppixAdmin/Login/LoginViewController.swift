//
//  LoginViewController.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 23/10/2025.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController {
    // UI Elements
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.backgroundColor = UIColor(white: 1, alpha: 0.1)
        tf.textColor = .black
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.white.cgColor
        tf.setLeftPaddingPoints(12)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 1, alpha: 0.1)
        tf.textColor = .black
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.white.cgColor
        tf.setLeftPaddingPoints(12)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign In", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.layer.cornerRadius = 22
        btn.layer.borderWidth = 2
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
   
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo2")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        navigationController?.setNavigationBarHidden(true, animated: false)
      
    }
        

    
    private func setupUI() {
        // Logo at the top
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            logoImageView.widthAnchor.constraint(equalToConstant: 120)
        ])
        // Add text fields and their underline borders
        let emailContainer = UIView()
        emailContainer.translatesAutoresizingMaskIntoConstraints = false
        emailContainer.addSubview(emailTextField)
        let emailUnderline = UIView()
        emailUnderline.backgroundColor = .gray
        emailUnderline.translatesAutoresizingMaskIntoConstraints = false
        emailContainer.addSubview(emailUnderline)
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: emailContainer.topAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 48),
            emailUnderline.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailUnderline.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor),
            emailUnderline.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor),
            emailUnderline.heightAnchor.constraint(equalToConstant: 2),
            emailUnderline.bottomAnchor.constraint(equalTo: emailContainer.bottomAnchor)
        ])
        let passwordContainer = UIView()
        passwordContainer.translatesAutoresizingMaskIntoConstraints = false
        passwordContainer.addSubview(passwordTextField)
        let passwordUnderline = UIView()
        passwordUnderline.backgroundColor = .gray
        passwordUnderline.translatesAutoresizingMaskIntoConstraints = false
        passwordContainer.addSubview(passwordUnderline)
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: passwordContainer.topAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 48),
            passwordUnderline.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor),
            passwordUnderline.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
            passwordUnderline.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor),
            passwordUnderline.heightAnchor.constraint(equalToConstant: 2),
            passwordUnderline.bottomAnchor.constraint(equalTo: passwordContainer.bottomAnchor)
        ])
        // VStack for the two fields
        let fieldsStack = UIStackView(arrangedSubviews: [emailContainer, passwordContainer])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 12
        fieldsStack.translatesAutoresizingMaskIntoConstraints = false
        // Main vertical stack
        let stackView = UIStackView(arrangedSubviews: [fieldsStack, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 22
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emailContainer.heightAnchor.constraint(equalToConstant: 50),
            passwordContainer.heightAnchor.constraint(equalToConstant: 50),
            loginButton.heightAnchor.constraint(equalToConstant: 48),
         
        ])
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
       
    }
    
    @objc private func loginTapped() {
        
        Auth.auth().signIn(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { authResult, error in
            if let error = error {
                print("Login failed: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Login Failed", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                print("Login successful")
                let VC = self.storyboard?.instantiateViewController(withIdentifier: "HomeView") as! UITabBarController
                self.navigationController?.pushViewController(VC, animated: true)
                
             
            }
            
            print("Login tapped")
        }
    }
    

}

private extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
