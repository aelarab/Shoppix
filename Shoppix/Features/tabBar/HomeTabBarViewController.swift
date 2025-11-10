//
//  HomeTabBarViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 30/10/2025.
//

import UIKit
import RxSwift

class HomeTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarIntiliaze ()
        applySavedTheme()
    }

    func tabBarIntiliaze (){
        let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
           homeVC.tabBarItem = UITabBarItem(
               title: "Home",
               image: UIImage(systemName: "house"),
               selectedImage: UIImage(systemName: "house.fill")
           )
           let homeNav = UINavigationController(rootViewController: homeVC)
        
//        let categoriesVC = CategoriesViewController(nibName: "CategoriesViewController", bundle: nil)
//            categoriesVC.tabBarItem = UITabBarItem(
//                title: "Categories",
//                image: UIImage(systemName: "square.grid.2x2"),
//                selectedImage: UIImage(systemName: "square.grid.2x2.fill")
//            )
//            let categoriesNav = UINavigationController(rootViewController: categoriesVC)
//
//
//
        let meVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
           meVC.tabBarItem = UITabBarItem(
               title: "Me",
               image: UIImage(systemName: "person"),
               selectedImage: UIImage(systemName: "person.fill")
           )
           let meNav = UINavigationController(rootViewController: meVC)
        
        let shoppingCartVC = ShoppingCartViewController(nibName: "ShoppingCartViewController", bundle: nil)
        shoppingCartVC.tabBarItem = UITabBarItem(
            title: "Cart",
            image: UIImage(systemName: "cart.circle"),
            selectedImage: UIImage(systemName: "cart.circle.fill")
        )
        let cartNav = UINavigationController(rootViewController: shoppingCartVC)
        
        UITabBar.appearance().tintColor = UIColor(named: "mainColor")
          UITabBar.appearance().unselectedItemTintColor = .gray

        self.viewControllers = [homeNav, cartNav, meNav]
    }

    
    private func applySavedTheme() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }

}
