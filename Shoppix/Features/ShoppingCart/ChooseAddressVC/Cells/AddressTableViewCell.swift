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
    
    @IBOutlet weak var isDefaultAddressImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        isDefaultAddressImageView.isHidden = true
    }
    
    
    @IBAction func selectedAddressButtonTapped(_ sender: UIButton) {
        isAddressSelected.toggle()
        let buttonImageName = isAddressSelected ? "smallcircle.fill.circle.fill" : "circle"
        selectedAddressButton.setImage(UIImage(systemName: buttonImageName), for: .normal)
    }
}

