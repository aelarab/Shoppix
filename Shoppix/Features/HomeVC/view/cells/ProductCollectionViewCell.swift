//
//  ProductCollectionViewCell.swift
//  SHOPPIX
//
//  Created by adham ragap on 23/10/2025.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var productStack: UIStackView!
    var onDeleteTapped: (() -> Void)?
    
   
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
       
        productStack.layer.borderWidth = 1
        productStack.layer.cornerRadius = productStack.frame.height / 6
        image.layer.cornerRadius = image.frame.height / 6
        productStack.layer.borderColor = UIColor(named: "mainColor")?.cgColor
        
    }
   
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            
            productStack.layer.borderColor = UIColor(named: "mainColor")?.cgColor
        }

    }
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        onDeleteTapped?()
    }
}
