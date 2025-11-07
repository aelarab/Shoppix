//
//  CollectionViewCell.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 05/11/2025.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var brandImg: UIImageView!
    
    @IBOutlet weak var itemsNum: UILabel!
    @IBOutlet weak var brandTitle: UILabel!
    
    @IBAction func deleteCat(_ sender: Any) {
        onDeleteRequested?()
    }
    
    @IBAction func editeCat(_ sender: Any) {
        onEditRequested?()
    }
    @IBOutlet weak var editeBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    var editCat: (()->())?
    var deleteCat: (()->())?
    var onEditRequested: (() -> Void)?
    var onDeleteRequested: (() -> Void)?
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
        
        brandImg.layer.cornerRadius = 12
        brandImg.layer.masksToBounds = true
        brandImg.contentMode = .scaleAspectFit
        brandImg.backgroundColor = UIColor.systemGray6
        
        brandTitle.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        brandTitle.textColor = UIColor.label
        
        itemsNum.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        itemsNum.textColor = UIColor.black
        
        // Edit button
        styleButton(editeBtn, systemName: "gearshape")
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
