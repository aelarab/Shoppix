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
    
    
    // MARK: - Properties
    private let viewModel = ChoosePaymentViewModel()
    
       //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
setupUI()
        setupTableView()
    }

   //MARK: - Behaviour
    private func setupUI() {
        continueToPaymentButton.layer.cornerRadius = continueToPaymentButton.frame.height / 2
        continueToPaymentButton.isEnabled = false
        continueToPaymentButton.alpha = 0.5
    }
    
    func setupTableView(){
        paymentsTableView.delegate = self
        paymentsTableView.dataSource = self
        paymentsTableView.register(UINib(nibName: "PaymentsTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentsTableViewCell")
    }
    
       //MARK: - Actions
    
    @IBAction func continueToPaymentButtonTapped(_ sender: UIButton) {
        guard let selectedPayment = viewModel.selectedPayment else { return }
        
        let placeOrderVC = PlaceOrderViewController(nibName: "PlaceOrderViewController", bundle: nil)
        placeOrderVC.selectedPaymentMethod = selectedPayment
        navigationController?.pushViewController(placeOrderVC, animated: true)
    }
    
}

   //MARK: - TableView Methods
extension ChoosePaymentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.paymentSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.paymentOptions[section].count
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return viewModel.paymentSections[section]
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentsTableViewCell", for: indexPath) as! PaymentsTableViewCell
        let paymentTitle = viewModel.paymentOptions[indexPath.section][indexPath.row]
        cell.paymentTitleLabel.text = paymentTitle
        
        if paymentTitle == viewModel.selectedPayment {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectPayment(at: indexPath)
        tableView.reloadData()
        
        continueToPaymentButton.isEnabled = viewModel.isPaymentSelected()
        continueToPaymentButton.alpha = viewModel.isPaymentSelected() ? 1.0 : 0.5
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
