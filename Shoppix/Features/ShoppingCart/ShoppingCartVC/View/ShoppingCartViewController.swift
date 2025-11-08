//
//  ShoppingCartViewController.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 25/10/2025.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa
import FirebaseAuth


class ShoppingCartViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = ShoppingCartViewModel()
    private let disposeBag = DisposeBag()
    
    
    //MARK: - outlets
    
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var emptyCartView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - lIfeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        viewModel.refreshTrigger.accept(())
        bindViewModel()
        //   fetchCartItems()
        
        //        checkoutButton.layer.cornerRadius = checkoutButton.frame.height / 2
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: - Behavior
    private func setupUI() {
        checkoutButton.layer.cornerRadius = checkoutButton.frame.height / 2
        emptyCartView.isHidden = true
        activityIndicator.hidesWhenStopped = true
    }
    
    func setupTableView(){
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        itemsTableView.register(UINib(nibName: "ShoppingCartTableViewCell", bundle: nil), forCellReuseIdentifier: "ShoppingCartTableViewCell")
        itemsTableView.refreshControl = UIRefreshControl()
        itemsTableView.refreshControl?.addTarget(self, action: #selector(refreshCart), for: .valueChanged)
    }
    
    @objc private func refreshCart() {
        viewModel.refreshTrigger.accept(())
    }
    
    private func bindViewModel() {
        viewModel.cartItems
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?.itemsTableView.reloadData() })
            .disposed(by: disposeBag)
        
        viewModel.totalPrice
            .map { "Total: $\(String(format: "%.2f", $0))" }
            .bind(to: totalPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isEmpty
            .bind(onNext: { [weak self] empty in
                self?.emptyCartView.isHidden = !empty
                self?.itemsTableView.isHidden = empty
                self?.totalPriceLabel.isHidden = empty
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .subscribe(onNext: { [weak self] msg in self?.showError(message: msg) })
            .disposed(by: disposeBag)
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    //MARK: - Actions
    
    @IBAction func proceedToCheckoutTapped(_ sender: UIButton) {
        if viewModel.isCartEmpty() {
            showError(message: "Your cart is empty")
            return
        }
        
        let addressVC = ChooseAddressViewController(nibName: "ChooseAddressViewController", bundle: nil)
        navigationController?.pushViewController(addressVC, animated: true)
    }
}


extension ShoppingCartViewController: UITableViewDelegate, UITableViewDataSource, ShoppingCartCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cartItems.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCartTableViewCell", for: indexPath) as! ShoppingCartTableViewCell
        let item = viewModel.cartItems.value[indexPath.row]
        
        cell.configure(
            with: item.title ?? "Unknown Product",
            brandName: extractBrandFromTitle(item.title ?? ""),
            image: nil,
            pricePerItem: Double(item.price ?? "0") ?? 0,
            quantity: item.quantity
        )
        cell.delegate = self
        
        if let urlString = viewModel.getImageUrl(for: item), let url = URL(string: urlString) {
            cell.itemImageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
        
        return cell
    }
    
    func didUpdateQuantity(for cell: ShoppingCartTableViewCell, newQuantity: Int, totalItemPrice: Double) {
        guard let indexPath = itemsTableView.indexPath(for: cell) else { return }
        let item = viewModel.cartItems.value[indexPath.row]
        if newQuantity == 0 {
            viewModel.deleteItemTrigger.accept(item)
        } else {
            viewModel.updateQuantityTrigger.accept((item, newQuantity))
        }
    }
    
    private func extractBrandFromTitle(_ title: String) -> String {
        title.components(separatedBy: " ").first ?? "Shoppix"
    }
}
