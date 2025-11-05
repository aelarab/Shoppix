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
        guard let userId = UserDefaults.standard.string(forKey: "userId") else { return }
        
        let request = NSFetchRequest<NSManagedObject>(entityName: "CartProduct")
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            cartItems = try context.fetch(request)
            print("🛒 Loaded \(cartItems.count) cart items.")
            itemsTableView.reloadData()
            updateTotalPrice()
        } catch {
            print("❌ Failed to fetch cart items: \(error.localizedDescription)")
        }
    }
    func updateTotalPrice() {
        var total: Double = 0.0
        
        for item in cartItems {
            if let priceString = item.value(forKey: "price") as? String,
               let price = Double(priceString) {
                total += price
            }
        }
        
        totalPriceLabel.text = "Total: $\(String(format: "%.2f", total))"
    }

    
       //MARK: - Actions
    
    @IBAction func proceedToCheckoutTapped(_ sender: UIButton) {
       let addressVC = ChooseAddressViewController(nibName: "ChooseAddressViewController", bundle: nil)
        navigationController?.pushViewController(addressVC, animated: true)
    }
    
}

extension ShoppingCartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCartTableViewCell", for: indexPath) as! ShoppingCartTableViewCell
            
            let cartItem = cartItems[indexPath.row]
            let title = cartItem.value(forKey: "title") as? String ?? "Unknown"
            let price = Double(cartItem.value(forKey: "price") as? String ?? "0") ?? 0
            let imageUrl = cartItem.value(forKey: "image") as? String ?? ""
            
            cell.configure(with: title, brandName: "", image: nil, pricePerItem: price, quantity: 1)
            
            // Optional: load image using SDWebImage
            if let imageView = cell.itemImageView, let url = URL(string: imageUrl) {
                imageView.sd_setImage(with: url)
            }
            
            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    
}
