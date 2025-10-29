//
//  ProductCell.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 26/10/2025.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productTitle: UILabel!
    
    @IBOutlet weak var productPrice: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!

    @IBOutlet weak var deleteBtn: UIButton!
    
    var deleteProduct: (()->())?
    var editProduct: (()->())?
    
    @IBAction func editProduct(_ sender: UIButton) {
        editProduct?()
    }
    
    @IBAction func deleteProduct(_ sender: UIButton) {
        deleteProduct?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Card style
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.25
        layer.masksToBounds = false
        
        // Product image
        productImage.layer.cornerRadius = 12
        productImage.layer.masksToBounds = true
        productImage.contentMode = .scaleAspectFill
        productImage.backgroundColor = UIColor.systemGray6
        
        // Title label
        productTitle.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        productTitle.textColor = UIColor.label
        
        // Price label
        productPrice.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        productPrice.textColor = UIColor.black
        
        // Edit button
        styleButton(editBtn, systemName: "gearshape")
        // Delete button
        styleButton(deleteBtn, systemName: "trash")
    }
    
    private func styleButton(_ button: UIButton, systemName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        button.tintColor = UIColor.black
        button.backgroundColor = systemName == "trash" ? UIColor.clear : UIColor.clear
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.masksToBounds = true
        button.layer.borderWidth = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure shadow and rounded corners are applied
        layer.cornerRadius = 20
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
        contentView.frame = bounds.inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
    }
}
