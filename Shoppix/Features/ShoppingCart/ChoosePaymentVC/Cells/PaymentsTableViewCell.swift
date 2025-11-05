//
//  PaymentsTableViewCell.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 26/10/2025.
//

import UIKit

class PaymentsTableViewCell: UITableViewCell {
       //MARK: - outlets
    
    @IBOutlet weak var paymentButton: UIButton!
    
    @IBOutlet weak var paymentTitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func paymentButtonTapped(_ sender: UIButton) {
        paymentButton.isSelected = !paymentButton.isSelected
        let imageName = paymentButton.isSelected ? "smallcircle.fill.circle.fill" : "circle"
        paymentButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
}
