//
//  ProductViewModel.swift
//  SHOPPIX
//
//  Created by adham ragap on 30/10/2025.
//

import Foundation
protocol SendDataOnVendorDelegete {
    func sendProudctsOnVendor(product:ProductModel)
}
class ProductViewModel{
    var delegete:SendDataOnVendorDelegete?
    init(delegete:SendDataOnVendorDelegete){
        self.delegete = delegete
    }
    func getPorductsFromServer (vendor:String){
        let shopifyToken = ProcessInfo.processInfo.environment["SHOPIFY_ACCESS_TOKEN"] ?? ""
        NetworkManager.getData(url: "https://iosr1g1.myshopify.com/admin/api/2025-07/products.json?vendor=\(vendor)", headers: [
            "X-Shopify-Access-Token": shopifyToken,
            "Content-Type":"application/json"
        
        
        ]) { (productModel:ProductModel?, error) in
            if let error = error {
                       print("❌ Network error: \(error.localizedDescription)")
                       return
                   }
                    guard let model = productModel else {
                       print("⚠️ No valid product model")
                       self.delegete?.sendProudctsOnVendor(product: ProductModel(products: []))
                       return
                   }
                  if model.products.isEmpty {
                        print("⚠️ Products array is empty in response")
                        self.delegete?.sendProudctsOnVendor(product: ProductModel(products: []))
                        return
                    }
           
           
            self.delegete?.sendProudctsOnVendor(product: model)
           
        }
    }
}
