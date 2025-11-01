//
//  PriceRulesViewController.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 29/10/2025.
//

import UIKit

class PriceRulesViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource , PriceRuleDetialsDelegate {
    var rulesList:[PriceRule] = []
    var priceRuleViewModel = PriceRuleViewModel()
    var networkIndicator = UIActivityIndicatorView()
    var editOrAdd = ""
    private var locallyAddedRules: [PriceRule] = []
    private var emptyStateImageView: UIImageView?
    
    @IBOutlet weak var PriceRuleTable: UITableView!
    @IBAction func addPriceRule(_ sender: Any) {
        editOrAdd = "add"
        let priceRuleVC = self.storyboard?.instantiateViewController(withIdentifier: "PriceRuleDetialsViewController") as! PriceRuleDetialsViewController
        priceRuleVC.priceRuleViewModel = PriceRuleViewModel()
        priceRuleVC.selectedRule = PriceRule(allocationMethod: "across" , customerSelection: "all" ,targetSelection: "all", targetType: "line_item" )
        priceRuleVC.editOrAdd = editOrAdd
        priceRuleVC.delegate = self
        self.navigationController?.pushViewController(priceRuleVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        priceRuleViewModel.getAllPriceRules()
     
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        PriceRuleTable.delegate = self
        PriceRuleTable.dataSource = self
        setupNibCell()
        loadIndicator()
        setupEmptyStateImage()
        priceRuleViewModel.bindPriceRulesViewModelToController = {[weak self] in
            DispatchQueue.main.async {
                  guard let self = self else { return }
                  var fetchedRules = self.priceRuleViewModel.allPriceRules
                  for localRule in self.locallyAddedRules {
                      if !fetchedRules.contains(where: { $0.id == localRule.id }) {
                          fetchedRules.insert(localRule, at: 0)
                      }
                  }

                  self.rulesList = fetchedRules
                  self.PriceRuleTable.reloadData()
                  self.networkIndicator.stopAnimating()
                  self.updateEmptyStateImageVisibility()
              }
        }
    }
    func didAddNewPriceRule(newRule: PriceRule) {
        locallyAddedRules.append(newRule)
        rulesList.insert(newRule, at: 0)
        PriceRuleTable.reloadData()
        updateEmptyStateImageVisibility()

        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.priceRuleViewModel.getAllPriceRules()
        }
    }

    func setupEmptyStateImage() {
        let imageView = UIImageView(image: UIImage(named: "coupon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0 // Hidden by default
        self.view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120)
        ])
        emptyStateImageView = imageView
    }
    func updateEmptyStateImageVisibility() {
        emptyStateImageView?.alpha = rulesList.isEmpty ? 1 : 0
    }
    func setupNibCell(){
        let nib = UINib(nibName: "PriceRuleTableViewCell", bundle: nil)
        PriceRuleTable.register(nib, forCellReuseIdentifier: "PriceRuleTableViewCell")
    }
    
    func loadIndicator(){
        networkIndicator = UIActivityIndicatorView(style: .large)
        networkIndicator.center = self.view.center
        self.view.addSubview(networkIndicator)
        networkIndicator.startAnimating()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rulesList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PriceRuleTableViewCell") as! PriceRuleTableViewCell
        cell.calculatePriceRuleData(rule: rulesList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 245
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            let alert = UIAlertController(title: Constants.warning, message: Constants.confirmDeleteRule, preferredStyle: .alert)
            let actionDelete = UIAlertAction(title: Constants.delete, style: .destructive) { _ in
                self.priceRuleViewModel.deletePriceRule(priceRule: self.rulesList[indexPath.row])
                self.rulesList.remove(at: indexPath.row)
                self.PriceRuleTable.reloadData()
                self.updateEmptyStateImageVisibility()
            }
            let actionCancel = UIAlertAction(title: Constants.cancel, style: .cancel)
            alert.addAction(actionDelete)
            alert.addAction(actionCancel)
            self.present(alert, animated: true)
        }
        delete.image = UIImage(systemName: Constants.trashEditImage)
    
        let swipeActions = UISwipeActionsConfiguration(actions: [delete])
        
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        let edit = UIContextualAction(style: .normal, title: "Edit") {  (contextualAction, view, boolValue) in
            self.prepareForEdit(index: indexPath.row)
        }
        
        edit.image = UIImage(systemName: Constants.pencilEditImage)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [edit])
        
        return swipeActions
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let discountVC = self.storyboard?.instantiateViewController(withIdentifier: "discountPage") as! DiscountsViewController
        discountVC.priceRule = rulesList[indexPath.row]
        self.navigationController?.pushViewController(discountVC, animated: true)
    }
    func prepareForEdit(index: Int){
        editOrAdd = "edit"
        
        let priceRuleVC = self.storyboard?.instantiateViewController(withIdentifier: "PriceRuleDetialsViewController") as! PriceRuleDetialsViewController
        
        priceRuleVC.priceRuleViewModel = priceRuleViewModel
        priceRuleVC.selectedRule = rulesList[index]
        priceRuleVC.editOrAdd = editOrAdd
        priceRuleVC.delegate = self 
        self.navigationController?.pushViewController(priceRuleVC, animated: true)
        
    }

}

