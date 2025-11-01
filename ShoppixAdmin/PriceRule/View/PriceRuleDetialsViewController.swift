//
//  PriceRuleDetialsViewController.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 29/10/2025.
//

import UIKit
protocol PriceRuleDetialsDelegate: AnyObject {
    func didAddNewPriceRule(newRule: PriceRule)
}

class PriceRuleDetialsViewController: UIViewController {
    
    @IBOutlet weak var nameFieldld: UITextField!
    @IBOutlet weak var availabilityField: UITextField!
    @IBOutlet weak var disountQuantityField: UITextField!
    @IBOutlet weak var segmenteControle: UISegmentedControl!
    @IBOutlet weak var beginnigDate: UIDatePicker!
    @IBOutlet weak var endingDate: UIDatePicker!
    weak var delegate: PriceRuleDetialsDelegate?
    var networkIndicator : UIActivityIndicatorView!
    var priceRuleViewModel: PriceRuleViewModel!
    var selectedRule: PriceRule!
    var editOrAdd: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareEditingPanel()
        loadIndicator()
    }
    
    func loadIndicator(){
        networkIndicator = UIActivityIndicatorView(style: .large)
        networkIndicator.center = self.view.center
        self.view.addSubview(networkIndicator)
    }
    
    func prepareEditingPanel(){
        beginnigDate.minimumDate = Date()
        endingDate.minimumDate = Date()
        nameFieldld.text = ""
        disountQuantityField.text = ""
        
        if editOrAdd == "edit"{
            nameFieldld.text = selectedRule.title
            beginnigDate.date = prepareDate(dateString: selectedRule.startsAt!)
            endingDate.date = prepareDate(dateString: selectedRule.endsAt!)
            disountQuantityField.text = selectedRule.value
            if selectedRule.valueType == "fixed_amount" {
                segmenteControle.selectedSegmentIndex = 1
            }else{
                segmenteControle.selectedSegmentIndex = 0
            }
            availabilityField.text = String(selectedRule.usageLimit ?? 0)
        }
    }
    
    @IBAction func SaveEditing(_ sender: Any) {
        if checkingFieldsIfEmpty() {
            if checkDatesIfInTheRightRule(){
                if usageLimitIsInt(){
                    if segmentedControlMatchesAmount(){
                        setRuleData()
                        saveRuleToCloud()
                    }
                }
            }
        }
    }
    
    func checkingFieldsIfEmpty() -> Bool {
        if let nameText = nameFieldld.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           let discountQuantityText = disountQuantityField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           let availabilityText = availabilityField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            
            if nameText.isEmpty || discountQuantityText.isEmpty || availabilityText.isEmpty {
                CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.emptyFields)
                return false
            } else {
                return true
            }
        } else {
           
            CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.emptyFields)
            return false
        }
    }
    
    func checkDatesIfInTheRightRule() -> Bool {
        if beginnigDate.date < endingDate.date && beginnigDate.date != endingDate.date{
            
            return true
        }else{
            CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.wrongDateOrder)
            return false
        }
    }
    
    func usageLimitIsInt() -> Bool {
        if let availabilityField = availabilityField.text, let availability = Int(availabilityField), availability >= 1 {
                return true
        }else{
            CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.wrongUsageLimitNumber)
            return false
        }
    }
    
    func segmentedControlMatchesAmount() -> Bool {
        if Double(disountQuantityField.text!) == nil {
            CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.wrongAmountNumber)
            return false
        }
        
        if segmenteControle.selectedSegmentIndex == 0{
            if Double(disountQuantityField.text!)! > 100 {
                CustomAlerts.presentAlert(vc: self, title: Constants.error, message: Constants.wrongPercentage)
                return false
            }
            else{
                return true
            }
        }else{
            return true
        }
    }
    
    func setRuleData(){
        selectedRule.title = nameFieldld.text
        selectedRule.usageLimit = Int(availabilityField.text!)
        if Double(disountQuantityField.text!)! <= 0 {
            selectedRule.value = disountQuantityField.text
        }else{
            selectedRule.value = String(Double(disountQuantityField.text!)! * -1)
        }
        selectedRule.startsAt = beginnigDate.date.iso8601
        selectedRule.endsAt = endingDate.date.iso8601
        if segmenteControle.selectedSegmentIndex == 0{
            selectedRule.valueType = "percentage"
        }else{
            selectedRule.valueType = "fixed_amount"
        }
    }
    
    func saveRuleToCloud(){
        networkIndicator.startAnimating()
        if editOrAdd == "add" {
            priceRuleViewModel.addPriceRule(priceRule: selectedRule) { [weak self] rule in
                self?.selectedRule = rule
                self?.networkIndicator.stopAnimating()
                self?.delegate?.didAddNewPriceRule(newRule: rule)
                self?.navigationController?.popViewController(animated: true)
            }
        }
        else{
            priceRuleViewModel.updatePriceRule(priceRule: selectedRule) { [weak self] rule in
                self?.selectedRule = rule
                self?.networkIndicator.stopAnimating()
                self?.delegate?.didAddNewPriceRule(newRule: rule)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func prepareDate(dateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:dateString)!
        return date
    }
}
