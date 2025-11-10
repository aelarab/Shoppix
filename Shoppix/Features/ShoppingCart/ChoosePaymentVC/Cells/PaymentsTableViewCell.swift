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
    
    var onSelect: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        paymentButton.adjustsImageWhenHighlighted = false
    }
    
    
    func configure(with title: String, isSelected: Bool) {
        paymentTitleLabel.text = title
        let imageName = isSelected ? "smallcircle.fill.circle.fill" : "circle"
        paymentButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }

    @IBAction func paymentButtonTapped(_ sender: UIButton) {
        onSelect?()
    }
    
}
