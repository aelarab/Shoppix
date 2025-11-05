//
//  SettingsViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 29/10/2025.
//

import UIKit

class SettingsViewController: UIViewController {
       //MARK: - Outlets
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var currencyLabel: UILabel!
    
    @IBOutlet weak var addressStackView: UIStackView!
    
    @IBOutlet weak var currencyStackView: UIStackView!
    
    @IBOutlet weak var contactUsStackView: UIStackView!
    
    @IBOutlet weak var aboutUsStackView: UIStackView!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    // MARK: - Properties
    private let viewModel = SettingsViewModel()
    
       //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGestures()
setupUI()
        bindViewModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
       //MARK: - Behaviour
    
    private func setupUI() {
        logoutButton.layer.cornerRadius = logoutButton.frame.height / 2
        tabBarController?.tabBar.isHidden = true
        currencyLabel.text = viewModel.currentCurrency
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
    }

       //MARK: - Actions
    @objc private func addressTapped() {
        let addressVC = AddressViewController(nibName: "AddressViewController", bundle: nil)
        navigationController?.pushViewController(addressVC, animated: true)
    }

    @objc private func currencyTapped() {
        let alert = UIAlertController(title: "Select Currency", message: nil, preferredStyle: .actionSheet)
        
        ["EGP", "USD"].forEach { currency in
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
        print("Logout button tapped")
    }
}
