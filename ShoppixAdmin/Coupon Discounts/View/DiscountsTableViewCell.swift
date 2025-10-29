//
//  DiscountsTableViewCell.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 29/10/2025.
//

import UIKit

class DiscountsTableViewCell: UITableViewCell {

    @IBOutlet weak var discountName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
        contentView.backgroundColor = .systemGray6
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var frame: CGRect{
        get {
            return super.frame
        }
        set(newFrame){
            var frame = newFrame
            frame.origin.x += 8
            frame.origin.y += 8
            frame.size.width -= 2 * 8
            frame.size.height -= 2 * 8
            super.frame = frame
        }
    }
    
    func setDiscountData(discount: DiscountCode){
        discountName.text = discount.code
    }
    
    
    
}
