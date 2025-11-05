//
//  AddressTableViewCell.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 26/10/2025.
//

import UIKit

class AddressTableViewCell: UITableViewCell {
       //MARK: - Properties
    var isAddressSelected: Bool = false

    
   //MARK: - Outlets
    
    @IBOutlet weak var countryNameLabel: UILabel!
    
    @IBOutlet weak var specificAddressLabel: UILabel!
    
    @IBOutlet weak var selectedAddressButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func selectedAddressButtonTapped(_ sender: UIButton) {
        isAddressSelected.toggle()
        let buttonImageName = isAddressSelected ? "smallcircle.fill.circle.fill" : "circle"
        selectedAddressButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
    }
}
