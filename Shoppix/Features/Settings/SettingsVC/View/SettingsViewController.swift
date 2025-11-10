//
//  SettingsViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 29/10/2025.
//

import UIKit
import FirebaseAuth
import RxSwift

class SettingsViewController: UIViewController {
       //MARK: - Outlets
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var currencyLabel: UILabel!
    
    @IBOutlet weak var addressStackView: UIStackView!
    
    @IBOutlet weak var currencyStackView: UIStackView!
    
    @IBOutlet weak var contactUsStackView: UIStackView!
    
    @IBOutlet weak var aboutUsStackView: UIStackView!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var nightModeSwitch: UISwitch!
    
    
    // MARK: - Properties
    private let viewModel = SettingsViewModel()
    private let disposeBag = DisposeBag()
    
       //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGestures()
setupUI()
        bindViewModel()
        loadDefaultAddress()
        setupNightModeSwitch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
       //MARK: - Behaviour
    
    private func setupNightModeSwitch() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        nightModeSwitch.isOn = isDarkMode
        applyTheme(isDarkMode: isDarkMode)
        
        nightModeSwitch.addTarget(self, action: #selector(nightModeSwitchChanged(_:)), for: .valueChanged)
    }
    
    @objc private func nightModeSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isDarkMode")
        
        applyTheme(isDarkMode: sender.isOn)
        let themeName = sender.isOn ? "Dark" : "Light"
        print("Switched to \(themeName) mode")
    }
    
    private func applyTheme(isDarkMode: Bool) {
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
    
    
    private func loadDefaultAddress() {
           if Auth.auth().currentUser != nil {
               viewModel.loadDefaultAddress()
           } else {
               updateAddressLabel(with: nil)
           }
       }
    
    
    
    private func setupAddressLabel() {
        guard Auth.auth().currentUser != nil else {
            addressLabel.text = "Login To Access"
            addressLabel.textColor = .systemGray
            return
        }
        
        if let address = viewModel.defaultAddress.value {
            addressLabel.text = address.city
            addressLabel.textColor = .label
        } else {
            addressLabel.text = "Add Address"
            addressLabel.textColor = .systemGray
        }
    }
    
    private func setupUI() {
        logoutButton.layer.cornerRadius = logoutButton.frame.height / 2
        tabBarController?.tabBar.isHidden = true
        currencyLabel.text = CurrencyService.shared.currentCurrency
        setupAddressLabel()
        logoutButton.setTitle("Logout", for: .normal)
        designButton(button: logoutButton)
        
    }
    private func setupGestures() {
        addressStackView.isUserInteractionEnabled = true
        currencyStackView.isUserInteractionEnabled = true
        contactUsStackView.isUserInteractionEnabled = true
        aboutUsStackView.isUserInteractionEnabled = true
        
        let addressTap = UITapGestureRecognizer(target: self, action: #selector(addressTapped))
        let currencyTap = UITapGestureRecognizer(target: self, action: #selector(currencyTapped))
        let contactTap = UITapGestureRecognizer(target: self, action: #selector(contactUsTapped))
        let aboutUsTap = UITapGestureRecognizer(target: self, action: #selector(aboutUsTapped))
        addressStackView.addGestureRecognizer(addressTap)
        currencyStackView.addGestureRecognizer(currencyTap)
        contactUsStackView.addGestureRecognizer(contactTap)
        aboutUsStackView.addGestureRecognizer(aboutUsTap)
        
    }
    private func bindViewModel() {
        viewModel.onCurrencyChanged = { [weak self] newCurrency in
            self?.currencyLabel.text = newCurrency
        }
        
        viewModel.defaultAddress
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] address in
                self?.updateAddressLabel(with: address)
            })
            .disposed(by: disposeBag)
    }

    private func updateAddressLabel(with address: ShopifyAddress?) {
        if let address = address {
            addressLabel.text = address.city
            addressLabel.textColor = .label
            print("Settings - Updated address label to: \(address.city)")
        } else {
            addressLabel.text = "Add Address"
            addressLabel.textColor = .systemGray
            print("Settings - No default address found")
        }
    }
    
    private func showLoginAlert() {
        let alert = UIAlertController(title: "Login Required", message: "Please sign in to add items to your favorites.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
            let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.setViewControllers([loginVC], animated: true)
              }))
              self.present(alert, animated: true)
    }
    


       //MARK: - Actions
    @objc private func addressTapped() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            showLoginAlert()
            return
        }
        let addressVC = AddressViewController(nibName: "AddressViewController", bundle: nil)
        navigationController?.pushViewController(addressVC, animated: true)
    }

    @objc private func currencyTapped() {
        let alert = UIAlertController(title: "Select Currency", message: nil, preferredStyle: .actionSheet)
        
        CurrencyService.shared.getAvailableCurrencies().forEach { currency in
            alert.addAction(UIAlertAction(title: currency, style: .default, handler: { _ in
                self.viewModel.updateCurrency(to: currency)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func contactUsTapped() {
        let contactUsVC = ContactUsViewController(nibName: "ContactUsViewController", bundle: nil)
        navigationController?.pushViewController(contactUsVC, animated: true)
    }
    @objc private func aboutUsTapped() {
        let aboutUsVC = AboutUsViewController(nibName: "AboutUsViewController", bundle: nil)
        navigationController?.pushViewController(aboutUsVC, animated: true)
    }
    
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            showLoginAlert()
            return
        }
        self.clearUserDefaults()
        try? Auth.auth().signOut()
        let landVC = LandSceenViewController(nibName: "LandSceenViewController", bundle: nil)
            let nav = UINavigationController(rootViewController: landVC)
        if let sceneDelegate = UIApplication.shared.connectedScenes
               .first?.delegate as? SceneDelegate {
               sceneDelegate.window?.rootViewController = nav
           }
    }
}
