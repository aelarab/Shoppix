//
//  FavoriteTableViewCell.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 10/11/2025.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
