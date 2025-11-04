//
//  ReviewCellTableViewCell.swift
//  SHOPPIX
//
//  Created by adham ragap on 31/10/2025.
//

import UIKit

class ReviewCellTableViewCell: UITableViewCell {
    @IBOutlet weak var reviewName: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    @IBOutlet weak var personImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        personImage.layer.cornerRadius = personImage.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
