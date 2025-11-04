//
//  ProductDetailViewModel.swift
//  SHOPPIX
//
//  Created by adham ragap on 31/10/2025.
//

import Foundation

protocol sendProductDetailsDelegete{
    func sendProductDetails(productDetail:SingleProductModel)
    func showError(message: String)
}
class ProductDetailViewModel {
    var delegete: sendProductDetailsDelegete?
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
    
}
