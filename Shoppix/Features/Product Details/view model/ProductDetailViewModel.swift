//
//  ProductDetailViewModel.swift
//  SHOPPIX
//
//  Created by adham ragap on 31/10/2025.
//

import Foundation
import RxSwift
import FirebaseAuth

protocol sendProductDetailsDelegete{
    func sendProductDetails(productDetail:SingleProductModel)
    func showError(message: String)
    func showCartSuccess(message: String)
}
class ProductDetailViewModel {
    var delegete: sendProductDetailsDelegete?
    private let disposeBag = DisposeBag()
    
    init(delegete:sendProductDetailsDelegete){
        self.delegete = delegete
    }
    func getProductDetailsFromServer(productId:Int){
        let shopifyToken = ProcessInfo.processInfo.environment["SHOPIFY_ACCESS_TOKEN"] ?? ""
        NetworkManager.getData(url: "https://iosr1g1.myshopify.com/admin/api/2025-07/products/\(productId).json", headers: [
            "X-Shopify-Access-Token":shopifyToken,
            "Content-Type":"application/json"
        ]) { (detailsRespone:SingleProductModel?, error) in
            if let error = error {
                self.delegete?.showError(message: error.localizedDescription)
                return
            }
            guard let detailsRespone = detailsRespone else {
                self.delegete?.showError(message: "This product is no longer available.")
                return
            }
            self.delegete?.sendProductDetails(productDetail: detailsRespone)
        }
    }
        
        
    func addToCart(product: Product, variant: Variant) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            delegete?.showError(message: "Please log in to add items to your cart.")
            return
        }
        
        ShopifyCartService.shared.addToCart(
            product: product,
            variant: variant,
            userEmail: userEmail
        )
        .observe(on: MainScheduler.instance)
        .subscribe(
            onNext: { [weak self] success in
                if success {
                    self?.delegete?.showCartSuccess(message: "\(product.title) was added to your cart!")
                } else {
                    self?.delegete?.showError(message: "Couldn't add to cart. Please try again.")
                }
            },
            onError: { [weak self] error in
                self?.delegete?.showError(message: "Failed to add to cart: \(error.localizedDescription)")
            }
        )
        .disposed(by: disposeBag)
    }
    }
    
    

