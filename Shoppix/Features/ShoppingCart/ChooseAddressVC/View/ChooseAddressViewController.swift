//
//  ChooseAddressViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 26/10/2025.
//

import UIKit

class ChooseAddressViewController: UIViewController {
   //MARK: - Outlets
    
    @IBOutlet weak var addressesTableVIew: UITableView!
    @IBOutlet weak var continueToPaymentButton: UIButton!
    
       //MARK: - Properties
//    private var addresses: [AddressEntity] = []
//    private var selectedAddress: AddressEntity?
//
    override func viewDidLoad() {
        super.viewDidLoad()
        continueToPaymentButton.layer.cornerRadius = continueToPaymentButton.frame.height / 2
      //  setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAddresses()
    }
    
    
       //MARK: - Behaviour
//    func setupTableView(){
//        addressesTableVIew.delegate = self
//        addressesTableVIew.dataSource = self
//        addressesTableVIew.register(UINib(nibName: "AddressTableViewCell", bundle: nil), forCellReuseIdentifier: "AddressTableViewCell")
//    }
    
    private func loadAddresses() {
     //   addresses = AddressService.shared.fetchAddresses()
        addressesTableVIew.reloadData()
    }
    
    
    
    
    
       //MARK: - Actions
    
    @IBAction func continueToPaymentTapped(_ sender: UIButton) {
//        guard selectedAddress != nil else {
//                    let alert = UIAlertController(title: "SHOPPIX", message: "Please select an address to continue.", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default))
//                    present(alert, animated: true)
//                    return
//                }
//
//                let paymentsVC = ChoosePaymentViewController(nibName: "ChoosePaymentViewController", bundle: nil)
//                navigationController?.pushViewController(paymentsVC, animated: true)
//    }
    
}
}

   //MARK: - TableView Methods
extension ChooseAddressViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   //     return addresses.count
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addressesTableVIew.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as! AddressTableViewCell
//               let address = addresses[indexPath.row]
//
//               cell.countryNameLabel.text = "\(address.country ?? "") - \(address.city ?? "")"
//               cell.specificAddressLabel.text = address.address
//               cell.isAddressSelected = (address == selectedAddress)
//               let iconName = cell.isAddressSelected ? "smallcircle.fill.circle.fill" : "circle"
//               cell.selectedAddressButton.setImage(UIImage(systemName: iconName), for: .normal)
//
//               cell.selectedAddressButton.tag = indexPath.row
//               cell.selectedAddressButton.addTarget(self, action: #selector(selectAddress(_:)), for: .touchUpInside)
               
               return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    @objc private func selectAddress(_ sender: UIButton) {
        let selectedIndex = sender.tag
    //    selectedAddress = addresses[selectedIndex]
        addressesTableVIew.reloadData()
    }
    
}
