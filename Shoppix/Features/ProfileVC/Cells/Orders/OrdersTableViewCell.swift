//
//  OrdersTableViewCell.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 27/10/2025.
//

import UIKit

class OrdersTableViewCell: UITableViewCell {
   //MARK: - Outlets
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var orderDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func configure(with order: Order) {
        // Format and display order data
        priceLabel.text = formatPrice(order.total_price, currency: order.currency)
        orderDateLabel.text = formatDate(order.created_at)
    }
    
    private func formatPrice(_ price: String?, currency: String?) -> String {
        guard let price = price, let doublePrice = Double(price) else {
            return "N/A"
        }
        
        let currencySymbol = currency == "USD" ? "$" : "EGP"
        return String(format: "%.2f", doublePrice)
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "N/A" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM dd, yyyy"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
}
