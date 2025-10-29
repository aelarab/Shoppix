//
//  DiscountsViewController.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 29/10/2025.
//

import UIKit
class DiscountsViewController: UIViewController {
    
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var discountEditingCodePrompt: UIView!
    @IBOutlet weak var editingDiscountField: UITextField!
    @IBOutlet weak var couponTableView: UITableView!
    
    var dicountsViewModel = DiscountsViewModel()
    var discountList:[DiscountCode] = []
    var editOrAdd = ""
    var priceRule:PriceRule!
    var discountBeingHandled: DiscountCode!
    var selectedDiscountIndex: Int!
    var networkIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNibCell()
        loadIndicator()
        discountEditingCodePrompt.layer.cornerRadius = 16
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAllDiscounts()
    }
    
    func setupNibCell(){
        let nib = UINib(nibName: DiscountConstants.cellClassName , bundle: nil)
        couponTableView.register(nib, forCellReuseIdentifier: DiscountConstants.cellName)
    }
    
    func loadIndicator(){
        networkIndicator = UIActivityIndicatorView(style: .large)
        networkIndicator.center = self.view.center
        self.view.addSubview(networkIndicator)
        networkIndicator.startAnimating()
    }
    
    func getAllDiscounts(){
        dicountsViewModel.getAllDiscountCoupons(priceRule: priceRule) {[weak self] discountArr in
            self?.discountList = discountArr
            self?.couponTableView.reloadData()
            self?.networkIndicator.stopAnimating()
        }
    }
    
    func hideEditingDiscountPanel(){
        discountEditingCodePrompt.isHidden = true
        discountView.isHidden = true
    }
    
    func showEditingDiscountPanel(){
        discountEditingCodePrompt.isHidden = false
        discountView.isHidden = false
    }

    @IBAction func exitEditDiscountTitlePanel(_ sender: Any) {
        hideEditingDiscountPanel()
        editingDiscountField.text = ""
        couponTableView.reloadData()
    }
    
    @IBAction func doneEditingDiscount(_ sender: Any) {
        if editingDiscountField.text != "" {
            discountBeingHandled.code = editingDiscountField.text
            
            if editOrAdd == "add" {
                dicountsViewModel.addDiscountCode(discountCode: discountBeingHandled, priceRule: priceRule) { [weak self] returnedDiscount in
                    self?.discountList.append(returnedDiscount)
                    self?.couponTableView.reloadData()
                }
            }
            else {
                dicountsViewModel.updateDiscountCode(discountCode: discountBeingHandled, priceRule: priceRule) { [weak self] returnedDiscount in
                    self?.discountList[(self?.selectedDiscountIndex)!] = returnedDiscount
                    self?.couponTableView.reloadData()
                }
            }
            
            hideEditingDiscountPanel()
            editingDiscountField.text = ""
            
        }
    }
    
    @IBAction func addDiscount(_ sender: Any) {
        editOrAdd = "add"
        discountBeingHandled = DiscountCode(priceRuleId: priceRule.id)
        showEditingDiscountPanel()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension DiscountsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discountList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiscountConstants.cellName) as! DiscountsTableViewCell
        cell.setDiscountData(discount: discountList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editOrAdd = "edit"
        discountBeingHandled = discountList[indexPath.row]
        selectedDiscountIndex = indexPath.row
        showEditingDiscountPanel()
        editingDiscountField.text = discountList[indexPath.row].code
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: Constants.warning, message: Constants.confirmDeleteProduct, preferredStyle: .alert)
        let actionDelete = UIAlertAction(title: Constants.delete, style: .destructive) { _ in
            self.dicountsViewModel.deleteDiscountCode(discountCode: self.discountList[indexPath.row], priceRule: self.priceRule)
            self.discountList.remove(at: indexPath.row)
            self.couponTableView.reloadData()
        }
        let actionCancel = UIAlertAction(title: Constants.cancel, style: .cancel)
        alert.addAction(actionDelete)
        alert.addAction(actionCancel)
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension DiscountsViewController {
    class DiscountConstants {
        static let cellName = "discountCell"
        static let cellClassName = "DiscountsTableViewCell"
    }
}
