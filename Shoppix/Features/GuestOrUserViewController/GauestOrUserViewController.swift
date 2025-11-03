//
//  GauestOrUserViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 26/10/2025.
//

import UIKit

class GauestOrUserViewController: UIViewController {

    @IBOutlet weak var shppexLabel: UILabel!
    @IBOutlet weak var userButtonOutlet: UIButton!
    @IBOutlet weak var guestButtonOutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        shppexLabel.font = UIFont(name: "MarkerFelt-Thin", size: 30.0)
        userButtonOutlet.setTitle("User", for: .normal)
        guestButtonOutlet.setTitle("Guest", for: .normal)
        designViews(button: userButtonOutlet)
        designViews(button: guestButtonOutlet)
        
    }


   func designViews(button:UIButton){
       button.setTitleColor(UIColor(named: "inverseLabelColor"), for: .normal)
       button.backgroundColor = UIColor(named: "mainColor")
       button.layer.cornerRadius = button.frame.height / 4
      
       button.layer.borderWidth = 1
       button.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    @IBAction func userActionPressed(_ sender: UIButton) {
//        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
//        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func guestActionPressed(_ sender: Any) {
//        let homeVC = HomeViewController(nibName: "HomeViewController", bundle: nil)
//        navigationController?.pushViewController(homeVC, animated: true)
//        homeVC.navigationItem.backBarButtonItem?.tintColor = UIColor(named: "mainColor")
    }
    
    
    
    
    
    
//        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//            super.traitCollectionDidChange(previousTraitCollection)
//
//            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//                update()
//            }
//
//        }
//        private func update (){
//            designViews(view: userButtonOutlet)
//            designViews(view: guestButtonOutlet)
//
//        }


}
