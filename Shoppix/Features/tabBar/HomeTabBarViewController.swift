//
//  HomeTabBarViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 30/10/2025.
//

import UIKit

class HomeTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarIntiliaze ()
        // Do any additional setup after loading the view.
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
        
        
        UITabBar.appearance().tintColor = UIColor(named: "MainColor")
          UITabBar.appearance().unselectedItemTintColor = .gray
        
//
//        UITabBar.appearance().tintColor = UIColor(named: "MainColor")
//        UITabBar.appearance().unselectedItemTintColor = UIColor(named: "MainColor")
        self.viewControllers = [homeNav, meNav]
    }

}
