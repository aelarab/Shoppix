//
//  LandSceenViewController.swift
//  SHOPPIX
//
//  Created by adham ragap on 20/10/2025.
//

import UIKit


class LandSceenViewController: UIViewController {
    @IBOutlet weak var shoppixImage: UIImageView!
    @IBOutlet weak var shoppixLabel: UILabel!
    var charIndex = 0.0
    // ⚡️Sportivo
    override func viewDidLoad() {
        super.viewDidLoad()
        shoppixLabel.text = ""
        //shoppixLabel.textColor = UIColor(named: "MainColor")
        shoppixLabel.font = UIFont(name: "MarkerFelt-Thin", size: 50.0)
        let titleText = "SH🛒PPIX"
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.2 * charIndex , repeats: false) { timer in
                self.shoppixLabel.text?.append(letter)
            }
            charIndex += 1
           
        }
        let totalDuration = 0.2 * charIndex
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            //    self.goToNextScreen()
            }
    }
//    func goToNextScreen() {
//       // let homeTabBar = HomeTabBarViewController()
//        let guestOr = GauestOrUserViewController(nibName: "GauestOrUserViewController", bundle: nil)
//        navigationController?.pushViewController(guestOr, animated: true)
//        }
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
//        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//            update()
//        }
//
//    }
//    private func update (){
//        shoppixImage.image = UIImage(named: "Shoppix_dark")
//    }

}
