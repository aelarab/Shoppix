//
//  AddressViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 29/10/2025.
//

import UIKit
import RxSwift

class AddressViewController: UIViewController {
   //MARK: - Outlets
    
    @IBOutlet weak var addressCountryLabel: UILabel!
    @IBOutlet weak var addressGovernmentLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var addNewAddressButton: UIButton!
    
    // MARK: - Properties
    private let viewModel = AddressViewModel()
    private let disposeBag = DisposeBag()
    
       //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadDefaultAddress()
        setupUI()
        setupBindings()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadDefaultAddress()
    }
    
       //MARK: - Behaviour
    func setupUI(){
        addNewAddressButton.layer.cornerRadius = addNewAddressButton.frame.height / 2
        tabBarController?.tabBar.isHidden = true
        addNewAddressButton.setTitle("Add New Address", for: .normal)
        designButton(button: addNewAddressButton)
    }
    
    private func setupBindings() {
            // Bind to default address changes
            viewModel.defaultAddress
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] address in
                    print("Address updated in UI: \(address?.id ?? 0)")
                    self?.updateUI(with: address)
                })
                .disposed(by: disposeBag)
            
            // Bind to error messages
            viewModel.errorMessage
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] message in
                    guard !message.isEmpty else { return }
                    self?.showError(message: message)
                })
                .disposed(by: disposeBag)
       }
    
    private func updateUI(with address: ShopifyAddress?) {
        if let address = address {
            showAddressState(with: address)
        } else {
            showNoAddressState()
        }
    }
    
    private func showError(message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
    
    private func showAddressState(with address: ShopifyAddress) {
           addressCountryLabel.text = address.country
           addressGovernmentLabel.text = address.city
           phoneNumberLabel.text = address.phone ?? "No phone number"
           
           addressCountryLabel.isHidden = false
           addressGovernmentLabel.isHidden = false
           phoneNumberLabel.isHidden = false
           
           updateLabelStyles(forEmptyState: false)
       }
       
       private func showNoAddressState() {

           addressCountryLabel.text = "No Address Saved"
           addressCountryLabel.isHidden = false
  
           addressGovernmentLabel.isHidden = true
           phoneNumberLabel.isHidden = true
           
           updateLabelStyles(forEmptyState: true)
       }
       
       private func updateLabelStyles(forEmptyState isEmpty: Bool) {
           if isEmpty {
               addressCountryLabel.textColor = .systemGray
               addressCountryLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
               addressCountryLabel.textAlignment = .center
           } else {
               addressCountryLabel.textColor = .label
               addressCountryLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
               addressCountryLabel.textAlignment = .left
               
               addressGovernmentLabel.textColor = .label
               addressGovernmentLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
               
               phoneNumberLabel.textColor = .label
               phoneNumberLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
           }
       }
    
    
   //MARK: - Actions
    
    @IBAction func addNewAddressButtonTapped(_ sender: UIButton) {
        let addNewAddressVC = AddNewAddressViewController(nibName: "AddNewAddressViewController", bundle: nil)
        navigationController?.pushViewController(addNewAddressVC, animated: true)
    }
    

}
