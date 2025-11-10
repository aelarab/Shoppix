//
//  ProfileViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 27/10/2025.
//

import UIKit
import RxSwift

class ProfileViewController: UIViewController {
    
       //MARK: - Outlets
    
    @IBOutlet weak var welcomeUsernameLabel: UILabel!
    @IBOutlet weak var orderPriceLabel: UILabel!
    @IBOutlet weak var orderDateLabel: UILabel!
    
    //MARK: - Properties
    
    private let viewModel = ProfileViewModel()
    private let disposeBag = DisposeBag()
    private var cartButton: UIBarButtonItem!
    
       //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupnavBar()
        loadUserName()
        setupLastOrderData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

       //MARK: - Behaviour
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
    func setupLastOrderData(){
        guard UserDefaults.standard.string(forKey: "userId") != nil else {
            orderPriceLabel.text = "00000"
            orderDateLabel.text = "00/00/2000"
                return
            }
        orderPriceLabel.text = "128.0"
        orderDateLabel.text = "18/12/2000 + 02:00"


    }
        
    func setupnavBar(){
        navigationItem.title = "Me"

         cartButton = UIBarButtonItem(
            image: UIImage(systemName: "cart.circle"),
            style: .plain,
            target: self,
            action: #selector(cartTapped)
        )
        
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        
        if #available(iOS 16.0, *) {
                navigationItem.trailingItemGroups = [
                    UIBarButtonItemGroup(barButtonItems: [cartButton, favoriteButton], representativeItem: nil)
                ]
            } else {
                navigationItem.rightBarButtonItems = [favoriteButton, cartButton]
            }
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
