//
//  ChooseAddressViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 26/10/2025.
//

import UIKit
import RxSwift
import FirebaseAuth
import FirebaseFirestore


class ChooseAddressViewController: UIViewController {
   //MARK: - Outlets
    
    @IBOutlet weak var addressesTableVIew: UITableView!
    @IBOutlet weak var continueToPaymentButton: UIButton!
    @IBOutlet weak var emptyStateLabel: UILabel!
    

    
    //MARK: - Properties
    private var addresses: [ShopifyAddress] = []
    private var selectedAddress: ShopifyAddress?
    private let disposeBag = DisposeBag()
    private let viewModel = ChooseAddressViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBindings()
        loadAddresses()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    
       //MARK: - Behaviour

    private func setupUI() {
           continueToPaymentButton.layer.cornerRadius = continueToPaymentButton.frame.height / 2
           emptyStateLabel.isHidden = true
           emptyStateLabel.text = "No addresses found. Please add an address first."
       }
    
    func setupTableView(){
        addressesTableVIew.delegate = self
        addressesTableVIew.dataSource = self
        addressesTableVIew.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressTableViewCell")
    }
    
    private func setupBindings() {
            viewModel.addresses
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] addresses in
                    self?.addresses = addresses
                    self?.addressesTableVIew.reloadData()
                    self?.updateEmptyState()
                })
                .disposed(by: disposeBag)
            
            viewModel.errorMessage
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] message in
                    guard !message.isEmpty else { return }
                    self?.showError(message: message)
                })
                .disposed(by: disposeBag)
        }
        
        private func loadAddresses() {
            viewModel.loadAllAddresses()
        }
    
    private func updateEmptyState() {
        let isEmpty = addresses.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        addressesTableVIew.isHidden = isEmpty
        continueToPaymentButton.isEnabled = !isEmpty && selectedAddress != nil


    }

    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func saveSelectedAddress(_ address: ShopifyAddress) {
        ChooseAddressService.shared.saveSelectedAddress(address)
    }

    
    
       //MARK: - Actions
    
    @IBAction func continueToPaymentTapped(_ sender: UIButton) {

        guard selectedAddress != nil else {
                    let alert = UIAlertController(title: "SHOPPIX", message: "Please select an address to continue.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                    return
                }
        saveSelectedAddress(selectedAddress!)

                
                let paymentsVC = ChoosePaymentViewController(nibName: "ChoosePaymentViewController", bundle: nil)
                navigationController?.pushViewController(paymentsVC, animated: true)
    }

    

}

   //MARK: - TableView Methods
extension ChooseAddressViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   //     return addresses.count
        return addresses.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addressesTableVIew.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as! AddressTableViewCell

        let address = addresses[indexPath.row]
        
        // Configure text
        cell.countryNameLabel.text = "\(address.country) - \(address.city)"
        cell.specificAddressLabel.text = "\(address.address1) • \(address.phone ?? "No phone")"
        
        // Selection state
        let isSelected = address.id == selectedAddress?.id
        cell.isAddressSelected = isSelected
        let iconName = isSelected ? "smallcircle.fill.circle.fill" : "circle"
        cell.selectedAddressButton.setImage(UIImage(systemName: iconName), for: .normal)
        cell.isDefaultAddressImageView.isHidden = !(address.isDefault ?? false)
        
        // Fix button target
        cell.selectedAddressButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.selectedAddressButton.tag = indexPath.row
        cell.selectedAddressButton.addTarget(self, action: #selector(selectAddress(_:)), for: .touchUpInside)
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddress = addresses[indexPath.row]
        addressesTableVIew.reloadData()
        continueToPaymentButton.isEnabled = true
        
        // Print selected address for debugging
        if let selected = selectedAddress {
            print("Selected address: \(selected.address1), \(selected.city), \(selected.country)")
        }
    }
    
    @objc private func selectAddress(_ sender: UIButton) {
        let selectedIndex = sender.tag
    //    selectedAddress = addresses[selectedIndex]
        addressesTableVIew.reloadData()
        continueToPaymentButton.isEnabled = true
        
        // Print selected address for debugging
        if let selected = selectedAddress {
            print("Selected address: \(selected.address1), \(selected.city), \(selected.country)")
        }
    }
}
