//
//  ChoosePaymentViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 26/10/2025.
//

import UIKit

class ChoosePaymentViewController: UIViewController {
       //MARK: - outlets
    
    @IBOutlet weak var paymentsTableView: UITableView!
    
    @IBOutlet weak var continueToPaymentButton: UIButton!
    
    
       //MARK: - Properties
    private let sections = ["Online Payments", "More Payment Options"]
    private let paymentOptions = [
        ["Apple Pay"],
        ["Cash on Delivery"]
    ]
    
       //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        continueToPaymentButton.layer.cornerRadius = continueToPaymentButton.frame.height / 2
        setupTableView()
    }

   //MARK: - Behaviour
    func setupTableView(){
        paymentsTableView.delegate = self
        paymentsTableView.dataSource = self
        paymentsTableView.register(UINib(nibName: "PaymentsTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentsTableViewCell")
    }
    
       //MARK: - Actions
    
    @IBAction func continueToPaymentButtonTapped(_ sender: UIButton) {
        let placeOrderVC = PlaceOrderViewController(nibName: "PlaceOrderViewController", bundle: nil)
        navigationController?.pushViewController(placeOrderVC, animated: true)
    }
    
}

   //MARK: - TableView Methods
extension ChoosePaymentViewController: UITableViewDelegate, UITableViewDataSource {

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentsTableViewCell", for: indexPath) as! PaymentsTableViewCell
        let paymentTitle = paymentOptions[indexPath.section][indexPath.row]
        cell.paymentTitleLabel.text = paymentTitle
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
           return sections.count
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return paymentOptions[section].count
       }
       
       func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
           return sections[section]
       }
    
    
}
