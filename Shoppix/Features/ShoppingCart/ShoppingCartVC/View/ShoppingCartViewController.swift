//
//  ShoppingCartViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 25/10/2025.
//

import UIKit

class ShoppingCartViewController: UIViewController {
       //MARK: - properties
    
       //MARK: - outlets
    
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
       //MARK: - lIfeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        checkoutButton.layer.cornerRadius = checkoutButton.frame.height / 2

    }
   //MARK: - Behavior
    func setupTableView(){
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        itemsTableView.register(UINib(nibName: "ShoppingCartTableViewCell", bundle: nil), forCellReuseIdentifier: "ShoppingCartTableViewCell")
    }
    
       //MARK: - Actions
    
    @IBAction func proceedToCheckoutTapped(_ sender: UIButton) {
       let addressVC = ChooseAddressViewController(nibName: "ChooseAddressViewController", bundle: nil)
        navigationController?.pushViewController(addressVC, animated: true)
    }
    
}

extension ShoppingCartViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCartTableViewCell", for: indexPath) as! ShoppingCartTableViewCell
        cell.configure(with: "Adidas Yeezy boost", brandName: "Adidas", image: UIImage(named: "shoes"), pricePerItem: 10, quantity: 1)
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    
}
