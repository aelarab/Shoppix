//
//  ProfileViewController.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 06/11/2025.
//

import UIKit
import FirebaseAuth
class ProfileViewController: UIViewController {
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully")
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
