//
//  ProductVariantCell.swift
//  ShopifyAdmin
//
//  Created by Ibrahim on 26/02/2024.
//

import UIKit

class ProductVariantCell: UICollectionViewCell {
    @IBOutlet weak var size: UILabel!
    
    @IBOutlet weak var color: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var quantity: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Card style
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.18
        layer.masksToBounds = false
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        
        // Labels styling
        let titleFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let valueFont = UIFont.systemFont(ofSize: 15, weight: .regular)
        let labelColor = UIColor.label
        let secondaryColor = UIColor.secondaryLabel
        
        size.font = titleFont
        size.textColor = labelColor
        size.layer.cornerRadius = 8
        size.layer.masksToBounds = true
        
        color.font = titleFont
        color.textColor = labelColor
        color.layer.cornerRadius = 8
        color.layer.masksToBounds = true
        
        price.font = valueFont
        price.textColor = UIColor.systemGreen
        price.layer.cornerRadius = 8
        price.layer.masksToBounds = true
        
        quantity.font = valueFont
        quantity.textColor = secondaryColor
        quantity.layer.cornerRadius = 8
        quantity.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
        contentView.frame = bounds.inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
    }
}
