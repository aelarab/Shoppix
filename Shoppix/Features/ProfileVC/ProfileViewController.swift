//
//  ProfileViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 27/10/2025.
//

import UIKit

class ProfileViewController: UIViewController {
    
       //MARK: - Outlets
    
    @IBOutlet weak var welcomeUsernameLabel: UILabel!
    
       //MARK: - Properties
    
    private let viewModel = ProfileViewModel()
    
       //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupnavBar()
        loadUserName()
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
        
    func setupnavBar(){
        navigationItem.title = "Me"

        let cartButton = UIBarButtonItem(
            image: UIImage(systemName: "cart"),
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
        print("cart tapped")
        let cartVC = ShoppingCartViewController(nibName: "ShoppingCartViewController", bundle: nil)
        navigationController?.pushViewController(cartVC, animated: true)
    }
    
    @objc func settingsTapped(){
        let settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
       //MARK: - Actions
    
    @IBAction func moreOrdersButtonTapped(_ sender: UIButton) {
        print("More orders tapped")
    }
    
    @IBAction func moreWishlistButtonTapped(_ sender: UIButton) {
        let favoritesVC = FavoriteViewController(nibName: "FavoriteViewController", bundle: nil)
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
}
