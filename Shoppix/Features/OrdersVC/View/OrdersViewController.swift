//
//  OrdersViewController.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 10/11/2025.
//

import UIKit
import FirebaseAuth

class OrdersViewController: UIViewController {
    private var orders: [Order] = []

    
    @IBOutlet weak var ordersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        setupTableView()
        loadOrders()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setupTableView() {
           ordersTableView.delegate = self
           ordersTableView.dataSource = self
           
           let nib = UINib(nibName: "OrdersTableViewCell", bundle: nil)
           ordersTableView.register(nib, forCellReuseIdentifier: "OrdersTableViewCell")
           
           ordersTableView.rowHeight = 120
           ordersTableView.separatorStyle = .singleLine
       }
    
    private func loadOrders() {
        guard let userEmail = Auth.auth().currentUser?.email else {
                showNoUserAlert()
                return
            }
            
            
            OrderService.shared.getOrdersForUser(email: userEmail) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let orders):
                        self?.orders = orders.sorted {
                            ($0.created_at ?? "") > ($1.created_at ?? "")
                        }
                        self?.ordersTableView.reloadData()
                        
                        if orders.isEmpty {
                            self?.showEmptyState()
                        } else {
                            self?.hideEmptyState()
                        }
                        
                    case .failure(let error):
                        print("Error loading orders: \(error.localizedDescription)")
                        self?.showErrorAlert(message: error.localizedDescription)
                    }
                }
            }
        }
    
    private func showEmptyState() {
            let emptyLabel = UILabel()
            emptyLabel.text = "No orders found"
            emptyLabel.textAlignment = .center
            emptyLabel.textColor = .systemGray
            emptyLabel.font = UIFont.systemFont(ofSize: 16)
            
            ordersTableView.backgroundView = emptyLabel
        }
    
    private func hideEmptyState() {
           ordersTableView.backgroundView = nil
       }
    
    private func showNoUserAlert() {
        let alert = UIAlertController(
            title: "Not Logged In",
            message: "Please log in to view your orders",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load orders: \(message)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadOrders()
        })
        present(alert, animated: true)
    }
    


}
extension OrdersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersTableViewCell", for: indexPath) as? OrdersTableViewCell else {
            return UITableViewCell()
        }
        
        let order = orders[indexPath.row]
        cell.configure(with: order)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let order = orders[indexPath.row]
        showOrderDetails(order)
    }
    
    private func showOrderDetails(_ order: Order) {
        let alert = UIAlertController(
            title: "Order #\(order.order_number ?? order.id)",
            message: """
            Total: \(order.total_price ?? "N/A") \(order.currency ?? "")
            Status: \(order.financial_status?.capitalized ?? "Pending")
            Date: \(formatDetailedDate(order.created_at))
            Items: \(order.line_items.count)
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
    }
    
    private func formatDetailedDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "N/A" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM dd, yyyy 'at' hh:mm a"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
}
