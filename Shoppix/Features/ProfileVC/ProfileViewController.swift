//
//  ProfileViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 27/10/2025.
//

import UIKit
import RxSwift
import CoreData
import FirebaseAuth

class ProfileViewController: UIViewController {
    
       //MARK: - Outlets
    
    @IBOutlet weak var welcomeUsernameLabel: UILabel!
    
    @IBOutlet weak var ordersSectionTitle: UILabel!
    @IBOutlet weak var ordersTableView: UITableView!
    
    @IBOutlet weak var favoritesTableView: UITableView!
    
    @IBOutlet weak var favoritesSectionTitle: UILabel!
    //MARK: - Properties
    
    private let viewModel = ProfileViewModel()
    private let disposeBag = DisposeBag()
    private var cartButton: UIBarButtonItem!
    private var favoritesButton: UIBarButtonItem!
    private var recentOrders: [Order] = []
    private var recentFavorites: [FavoriteProduct] = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
       //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupnavBar()
        loadUserName()
        setupTables()
        loadRecentData()
        setupNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRecentData()
        updateCartBadgeFromAPI()
    }

       //MARK: - Behaviour
    
    func setupNotification(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidUpdate),
            name: .cartDidUpdate,
            object: nil
        )
    }
    @objc private func cartDidUpdate() {
        updateCartBadgeFromAPI()
    }

    
    private func setupTables() {
            ordersTableView.delegate = self
            ordersTableView.dataSource = self
            ordersTableView.register(UINib(nibName: "OrdersTableViewCell", bundle: nil), forCellReuseIdentifier: "OrdersTableViewCell")
            ordersTableView.rowHeight = 60
            ordersTableView.separatorStyle = .singleLine
            
            favoritesTableView.delegate = self
            favoritesTableView.dataSource = self
            favoritesTableView.register(UINib(nibName: "FavoriteTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoriteTableViewCell")
            favoritesTableView.rowHeight = 60
            favoritesTableView.separatorStyle = .singleLine
            updateSectionTitles()
        }
        
        private func updateSectionTitles() {
            ordersSectionTitle.text = recentOrders.isEmpty ? "Recent Orders" : "Recent Orders (\(recentOrders.count))"
            favoritesSectionTitle.text = recentFavorites.isEmpty ? "Favorite Items" : "Favorite Items (\(recentFavorites.count))"
        }
    
    
    
    
    func loadUserName() {
        viewModel.getUserFullName { [weak self] fullName in
            DispatchQueue.main.async {
                if let name = fullName {
                    self?.welcomeUsernameLabel.text = "Welcome \(name)"
                } else {
                    self?.welcomeUsernameLabel.text = "Welcome, Guest"
                }
            }
        }
    }
    
    private func loadRecentData() {
            guard UserDefaults.standard.string(forKey: "userId") != nil else {
                recentOrders = []
                recentFavorites = []
                reloadTables()
                return
            }
            
            loadRecentOrders()
            loadRecentFavorites()
        }
        
        private func loadRecentOrders() {
            guard let userEmail = Auth.auth().currentUser?.email else {
                recentOrders = []
                reloadTables()
                return
            }
            
            OrderService.shared.getOrdersForUser(email: userEmail) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let orders):
                        self?.recentOrders = Array(orders.sorted {
                            ($0.created_at ?? "") > ($1.created_at ?? "")
                        }.prefix(4))
                        
                    case .failure(let error):
                        print("Error loading recent orders: \(error.localizedDescription)")
                        self?.recentOrders = []
                    }
                    
                    self?.reloadTables()
                }
            }
        }
        
        private func loadRecentFavorites() {
            guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                recentFavorites = []
                reloadTables()
                return
            }
            
            let request: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
            request.predicate = NSPredicate(format: "userId == %@", userId)
            
            do {
                let allFavorites = try context.fetch(request)
                recentFavorites = Array(allFavorites.prefix(4))
            } catch {
                recentFavorites = []
            }
            
            reloadTables()
        }
        
        private func reloadTables() {
            ordersTableView.reloadData()
            favoritesTableView.reloadData()
            updateSectionTitles()
            
                  }
    
    private func updateCartBadgeFromAPI() {
        guard let email = Auth.auth().currentUser?.email else {
            cartButton.showDotBadge(shouldShow: false)
            return
        }

        ShopifyCartService.shared.getCart(userEmail: email)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] draftOrders in
                let totalItems = draftOrders.flatMap { $0.line_items }.count
                self?.cartButton.showDotBadge(shouldShow: totalItems > 0)
            }, onError: { [weak self] _ in
                self?.cartButton.showDotBadge(shouldShow: false)
            })
            .disposed(by: disposeBag)
    }


        
    func setupnavBar(){
        navigationItem.title = "Me"

         cartButton = UIBarButtonItem(
            image: UIImage(systemName: "cart.circle"),
            style: .plain,
            target: self,
            action: #selector(cartTapped)
        )
        
        
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        
        if #available(iOS 16.0, *) {
                navigationItem.trailingItemGroups = [
                    UIBarButtonItemGroup(barButtonItems: [cartButton, settingsButton], representativeItem: nil)
                ]
            } else {
                navigationItem.rightBarButtonItems = [settingsButton, cartButton]
            }
        updateCartBadgeFromAPI()
    }
    
    @objc func cartTapped(){
        guard UserDefaults.standard.string(forKey: "userId") != nil else {
                showLoginAlert()
                return
            }
        let cartVC = ShoppingCartViewController(nibName: "ShoppingCartViewController", bundle: nil)
        navigationController?.pushViewController(cartVC, animated: true)
    }
    
    @objc func settingsTapped(){
        let settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    private func showLoginAlert() {
        let alert = UIAlertController(title: "Login Required", message: "Please sign in to add items to your favorites.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { _ in
            let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            self.navigationController?.setViewControllers([loginVC], animated: true)
              }))
              self.present(alert, animated: true)
    }
    
       //MARK: - Actions
    
    @IBAction func moreOrdersButtonTapped(_ sender: UIButton) {
        guard UserDefaults.standard.string(forKey: "userId") != nil else {
                showLoginAlert()
                return
            }
        let ordersVC = OrdersViewController(nibName: "OrdersViewController", bundle: nil)
        navigationController?.pushViewController(ordersVC, animated: true)
    }
    
    @IBAction func moreWishlistButtonTapped(_ sender: UIButton) {
        guard UserDefaults.standard.string(forKey: "userId") != nil else {
                showLoginAlert()
                return
            }
        let favoritesVC = FavoriteViewController(nibName: "FavoriteViewController", bundle: nil)
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    
}
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Orders Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ordersTableView {
            return min(recentOrders.count, 4)
        } else {
            return min(recentFavorites.count, 4)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ordersTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersTableViewCell", for: indexPath) as? OrdersTableViewCell else {
                return UITableViewCell()
            }
            
            let order = recentOrders[indexPath.row]
            cell.configure(with: order)
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTableViewCell", for: indexPath) as? FavoriteTableViewCell else {
                return UITableViewCell()
            }
            
            let favorite = recentFavorites[indexPath.row]
            
            cell.itemNameLabel.text = favorite.title ?? "Unknown Product"
            
            if let imageUrl = favorite.image, let url = URL(string: imageUrl) {
                cell.itemImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
            } else {
                cell.itemImageView.image = UIImage(named: "placeholder")
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == ordersTableView {
            let order = recentOrders[indexPath.row]
            showOrderDetails(order)
        } else {
            let favorite = recentFavorites[indexPath.row]
            navigateToProductDetails(favorite)
        }
    }
    
    private func showOrderDetails(_ order: Order) {
        let alert = UIAlertController(
            title: "Order #\(order.order_number ?? order.id)",
            message: """
            Total: \(order.total_price ?? "N/A") \(order.currency ?? "")
            Status: \(order.financial_status?.capitalized ?? "Pending")
            Date: \(formatDate(order.created_at))
            Items: \(order.line_items.count)
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "View Full Order", style: .default) { [weak self] _ in
            self?.moreOrdersButtonTapped(UIButton())
        })
        present(alert, animated: true)
    }
    
    private func navigateToProductDetails(_ favorite: FavoriteProduct) {
        Session.productId = Int(favorite.id)
        let productDetailsVC = ProductDetailsViewController(nibName: "ProductDetailsViewController", bundle: nil)
        navigationController?.pushViewController(productDetailsVC, animated: true)
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
extension UIBarButtonItem {
    func showDotBadge(shouldShow: Bool) {
        guard let view = self.value(forKey: "view") as? UIView else { return }

        view.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }

        guard shouldShow else { return }

        let dotSize: CGFloat = 8
        let dotView = UIView(frame: CGRect(x: view.frame.width - dotSize / 2, y: 2, width: dotSize, height: dotSize))
        dotView.backgroundColor = .systemRed
        dotView.layer.cornerRadius = dotSize / 2
        dotView.clipsToBounds = true
        dotView.tag = 999
        view.addSubview(dotView)
    }
}
