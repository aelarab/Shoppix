//
//  ShoppingCartViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 25/10/2025.
//

import UIKit
import CoreData


class ShoppingCartViewController: UIViewController {
       //MARK: - properties
    private var cartItems: [NSManagedObject] = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
       //MARK: - outlets
    
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
       //MARK: - lIfeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchCartItems()

        checkoutButton.layer.cornerRadius = checkoutButton.frame.height / 2

    }
   //MARK: - Behavior
    func setupTableView(){
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        itemsTableView.register(UINib(nibName: "ShoppingCartTableViewCell", bundle: nil), forCellReuseIdentifier: "ShoppingCartTableViewCell")
    }
    
    func fetchCartItems() {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            cartItems = []
            itemsTableView.reloadData()
            totalPriceLabel.text = "Total: $0.00"
            return
        }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "CartProduct")
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            cartItems = try context.fetch(request)
            
            // ENHANCED DEBUG: Print detailed cart contents
            print("=== DETAILED CART CONTENTS ===")
            for (index, item) in cartItems.enumerated() {
                let title = item.value(forKey: "title") as? String ?? "Unknown"
                let price = item.value(forKey: "price") ?? "N/A"
                let quantity = item.value(forKey: "quantity") ?? "N/A"
                let quantityType = type(of: quantity)
                
                print("Item \(index): \(title)")
                print("  - Price: \(price) (Type: \(type(of: price)))")
                print("  - Quantity: \(quantity) (Type: \(quantityType))")
                
                // Test different quantity retrievals
                if let q64 = item.value(forKey: "quantity") as? Int64 {
                    print("  - As Int64: \(q64)")
                }
                if let q32 = item.value(forKey: "quantity") as? Int32 {
                    print("  - As Int32: \(q32)")
                }
                if let q16 = item.value(forKey: "quantity") as? Int16 {
                    print("  - As Int16: \(q16)")
                }
                if let qInt = item.value(forKey: "quantity") as? Int {
                    print("  - As Int: \(qInt)")
                }
            }
            print("=====================")
            
            itemsTableView.reloadData()
            updateTotalPrice()
            print("Fetched \(cartItems.count) cart items for user: \(userId)")
        } catch {
            print("Failed to fetch cart items: \(error.localizedDescription)")
        }
    }
    func updateTotalPrice() {
        let total = cartItems.reduce(0.0) { result, item in
            let price: Double
            if let priceString = item.value(forKey: "price") as? String {
                price = Double(priceString) ?? 0
            } else {
                price = item.value(forKey: "price") as? Double ?? 0
            }
            
            let quantity: Int
            if let q = item.value(forKey: "quantity") as? Int64 {
                quantity = Int(q)
            } else if let q = item.value(forKey: "quantity") as? Int {
                quantity = q
            } else {
                quantity = 1
            }
            
            let itemTotal = price * Double(quantity)
            print("Item: \(item.value(forKey: "title") as? String ?? "Unknown") - Price: \(price) - Quantity: \(quantity) - Total: \(itemTotal)")
            return result + itemTotal
        }
        
        totalPriceLabel.text = "Total: $\(String(format: "%.2f", total))"
    }
    
    func extractBrandFromTitle(_ title: String) -> String {
        let words = title.components(separatedBy: " ")

        if let firstWord = words.first, firstWord.count > 2 {
            return firstWord.trimmingCharacters(in: .punctuationCharacters)
        }
        
        return "Shoppix"
    }

    
       //MARK: - Actions
    
    @IBAction func proceedToCheckoutTapped(_ sender: UIButton) {
       let addressVC = ChooseAddressViewController(nibName: "ChooseAddressViewController", bundle: nil)
        navigationController?.pushViewController(addressVC, animated: true)
    }
    
}

extension ShoppingCartViewController: UITableViewDelegate, UITableViewDataSource, ShoppingCartCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCartTableViewCell", for: indexPath) as! ShoppingCartTableViewCell
        
        let cartItem = cartItems[indexPath.row]
        let title = cartItem.value(forKey: "title") as? String ?? "Unknown"
        let price = Double(cartItem.value(forKey: "price") as? String ?? "0") ?? 0
        let imageUrl = cartItem.value(forKey: "image") as? String ?? ""
        
        let quantity: Int
        if let q = cartItem.value(forKey: "quantity") as? Int64 {
            quantity = Int(q)
        } else if let q = cartItem.value(forKey: "quantity") as? Int {
            quantity = q
        } else {
            quantity = 1
        }
        let brandName = extractBrandFromTitle(title)
        
        print("Configuring cell for: \(title) - Quantity: \(quantity)") // DEBUG
        
        cell.configure(with: title, brandName: brandName, image: nil, pricePerItem: price, quantity: quantity)
        cell.delegate = self
        
        if let imageView = cell.itemImageView, let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url)
        }
        
        return cell
    }
    
    // MARK: - ShoppingCartCellDelegate
    // MARK: - ShoppingCartCellDelegate
    func didUpdateQuantity(for cell: ShoppingCartTableViewCell, newQuantity: Int, totalItemPrice: Double) {
        guard let indexPath = itemsTableView.indexPath(for: cell) else { return }
        
        let cartItem = cartItems[indexPath.row]
        cartItem.setValue(Int64(newQuantity), forKey: "quantity")
        
        do {
            try context.save()
            updateTotalPrice()
            itemsTableView.reloadRows(at: [indexPath], with: .none)
        } catch {
            print("Failed to update quantity: \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = cartItems[indexPath.row]
            context.delete(itemToDelete)
            do {
                try context.save()
                cartItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                updateTotalPrice()
            } catch {
                print("Failed to delete item: \(error.localizedDescription)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
