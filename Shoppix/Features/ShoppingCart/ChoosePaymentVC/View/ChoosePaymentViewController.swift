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
        tabBarController?.tabBar.isHidden = true

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

    }

   //MARK: - Behaviour
    private func setupUI() {
        continueToPaymentButton.layer.cornerRadius = continueToPaymentButton.frame.height / 2
        continueToPaymentButton.isEnabled = false
        continueToPaymentButton.alpha = 0.5
        continueToPaymentButton.setTitle("Continue To Payment", for: .normal)
        designButton(button: continueToPaymentButton)
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

        switch selectedPayment.lowercased() {
        case "apple pay":
            placeOrderVC.selectedPaymentMethod = "apple_pay"
        case "cash on delivery":
            placeOrderVC.selectedPaymentMethod = "cash_on_delivery"
        default:
            placeOrderVC.selectedPaymentMethod = selectedPayment.lowercased()
        }

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentsTableViewCell",
                                                 for: indexPath) as! PaymentsTableViewCell
        
        let paymentName = viewModel.paymentOptions[indexPath.section][indexPath.row]
        cell.paymentTitleLabel.text = paymentName
        
        let isSelected = viewModel.isSelected(at: indexPath)
        let iconName = isSelected ? "smallcircle.fill.circle.fill" : "circle"
        cell.paymentButton.setImage(UIImage(systemName: iconName), for: .normal)
        
        // Setup button tap
        cell.paymentButton.tag = (indexPath.section * 10) + indexPath.row
        cell.paymentButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.paymentButton.addTarget(self, action: #selector(selectPayment(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc private func selectPayment(_ sender: UIButton) {
        let section = sender.tag / 10
        let row = sender.tag % 10
        let indexPath = IndexPath(row: row, section: section)
        
        viewModel.selectPayment(at: indexPath)
        paymentsTableView.reloadData()
        
        continueToPaymentButton.isEnabled = viewModel.selectedPaymentName() != nil
        continueToPaymentButton.alpha = continueToPaymentButton.isEnabled ? 1.0 : 0.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectPayment(at: indexPath)
        paymentsTableView.reloadData()
        
        continueToPaymentButton.isEnabled = viewModel.selectedPaymentName() != nil
        continueToPaymentButton.alpha = continueToPaymentButton.isEnabled ? 1.0 : 0.5
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
