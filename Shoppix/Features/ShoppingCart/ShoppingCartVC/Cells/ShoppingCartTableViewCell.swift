//
//  ShoppingCartTableViewCell.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 25/10/2025.
//

import UIKit

protocol ShoppingCartCellDelegate: AnyObject {
    func didUpdateQuantity(for cell: ShoppingCartTableViewCell, newQuantity: Int, totalItemPrice: Double)
}

class ShoppingCartTableViewCell: UITableViewCell {

    //MARK: - Properties
    var itemQuantity: Int = 0
    var pricePerItem: Double = 0
    weak var delegate: ShoppingCartCellDelegate?
    
    
       //MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var brandNameLabel: UILabel!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var priceContainerView: UIView!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        updatePriceLabel()

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        priceContainerView.layer.cornerRadius = priceContainerView.frame.height / 2

    }
    
       //MARK: - Behaviour
    
    private func setupUI() {
        priceContainerView.layer.borderWidth = 1
        priceContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        numberOfItemsLabel.text = "\(itemQuantity)"
    }
    
    @IBAction func minusButtonTapped(_ sender: UIButton) {
        guard itemQuantity > 0 else { return }
        itemQuantity -= 1
        numberOfItemsLabel.text = "\(itemQuantity)"
        updatePriceLabel()
    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        itemQuantity += 1
        numberOfItemsLabel.text = "\(itemQuantity)"
        updatePriceLabel()
    }
    
    private func updatePriceLabel() {
        let totalPrice = pricePerItem * Double(itemQuantity)
        priceLabel.text = String(format: "%.2f USD", totalPrice)
        delegate?.didUpdateQuantity(for: self, newQuantity: itemQuantity, totalItemPrice: totalPrice)
    }
    
    func configure(with itemName: String, brandName: String, image: UIImage?, pricePerItem: Double, quantity: Int) {
        self.itemNameLabel.text = itemName
        self.brandNameLabel.text = brandName
        self.itemImageView.image = image
        self.pricePerItem = pricePerItem
        self.itemQuantity = quantity
        self.numberOfItemsLabel.text = "\(quantity)"
        updatePriceLabel()
    }

}
