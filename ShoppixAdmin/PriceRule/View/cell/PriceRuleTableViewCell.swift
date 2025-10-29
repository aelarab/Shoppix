//
//  PriceRuleTableViewCell.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 29/10/2025.
//

import UIKit

class PriceRuleTableViewCell: UITableViewCell {

    @IBOutlet weak var typeOfRule: UILabel!
    @IBOutlet weak var ruleUsageAvailable: UILabel!
    @IBOutlet weak var quantityRule: UILabel!
    @IBOutlet weak var endTimeRule: UILabel!
    @IBOutlet weak var beginningTimeRule: UILabel!
    @IBOutlet weak var NameRule: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Card style
        layer.masksToBounds = false
        layer.cornerRadius = 18
        layer.shadowColor = UIColor.black.withAlphaComponent(0.10).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 12
        contentView.layer.cornerRadius = 18
        contentView.layer.masksToBounds = true
        backgroundColor = .clear
        contentView.backgroundColor = .secondarySystemBackground
        // Modern label styles
        NameRule.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        NameRule.textColor = .label
        typeOfRule.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        typeOfRule.textColor = .systemBlue
        ruleUsageAvailable.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        ruleUsageAvailable.textColor = .systemGray
        quantityRule.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        quantityRule.textColor = .systemGreen
        beginningTimeRule.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        beginningTimeRule.textColor = .systemGray2
        endTimeRule.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        endTimeRule.textColor = .systemGray2
        // Add padding to contentView
        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
  
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override var frame: CGRect{
        get {
            return super.frame
        }
        set(newFrame){
            var frame = newFrame
            frame.origin.x += 8
            frame.origin.y += 8
            frame.size.width -= 16
            frame.size.height -= 16
            super.frame = frame
        }
    }
    
    func calculatePriceRuleData(rule:PriceRule){
        NameRule.text = rule.title
        beginningTimeRule.text = getDate(dateString: rule.startsAt!)
        endTimeRule.text = getDate(dateString: rule.endsAt!)
        quantityRule.text = getQuantityField(rule:rule)
        ruleUsageAvailable.text = "\(String(rule.usageLimit ?? 0))"
        typeOfRule.text = rule.valueType
    }
    
    func getDate(dateString: String) -> String{
        let dateFormatter = DateFormatter()
          dateFormatter.locale = Locale(identifier: "en_US_POSIX")
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
          let date = dateFormatter.date(from:dateString)!
        return date.formatted(date: .long, time: .shortened)
    }
    
    func getQuantityField(rule:PriceRule) -> String{
        let amountText = rule.value!
        return amountText
    }
    
}
