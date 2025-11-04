//
//  AddressViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 29/10/2025.
//

import UIKit

class AddressViewController: UIViewController {
   //MARK: - Outlets
    
    @IBOutlet weak var addressCountryLabel: UILabel!
    
    @IBOutlet weak var addressGovernmentLabel: UILabel!
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var addNewAddressButton: UIButton!
    

       //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewAddressButton.layer.cornerRadius = addNewAddressButton.frame.height / 2
        tabBarController?.tabBar.isHidden = true

    }
    
   //MARK: - Actions
    
    @IBAction func addNewAddressButtonTapped(_ sender: UIButton) {
        let addNewAddressVC = AddNewAddressViewController(nibName: "AddNewAddressViewController", bundle: nil)
        navigationController?.pushViewController(addNewAddressVC, animated: true)
    }
    

}
