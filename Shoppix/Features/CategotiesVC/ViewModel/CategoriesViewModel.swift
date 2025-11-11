//
//  CategoriesViewModel.swift
//  Shoppix
//
//  Created by Abdelrahman Elaraby on 20/10/2025.
//

import Foundation

enum CategoryType: String, CaseIterable {
    case all = "/products.json"
    case men = "/products.json?collection_id=288493928511"
    case women = "/products.json?collection_id=288493961279"
    case kids = "/products.json?collection_id=288493994047"
    case sale = "/products.json?collection_id=288494026815"
}

enum SubFilterType: String, CaseIterable {
    case all = "ALL"
    case shoes = "SHOES"
    case accessories = "ACCESSORIES"
    case tshirts = "T-SHIRTS"
}

final class CategoryViewModel {
    
       //MARK: - Properties
    var products: [Product] = []
    var filteredProducts: [Product] = []
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    private var currentCategory: CategoryType = .all
    
       //MARK: - Behaviour
    func fetchProducts(for category: CategoryType) {
            currentCategory = category
            let fullURL = "\(NetworkConstants.baseURL)\(category.rawValue)"
            let headers = ["X-Shopify-Access-Token": NetworkConstants.token]

            NetworkManager.getData(url: fullURL, headers: headers) { (result: ProductModel?, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.onError?("Failed to fetch products: \(error.localizedDescription)")
                        return
                    }
                    guard let result = result else {
                        self.onError?("No data received")
                        return
                    }
                    self.products = result.products
                    self.filteredProducts = result.products
                    self.onDataUpdated?()
                }
            }
        }
        
        func applySubFilter(_ subFilter: SubFilterType) {
            guard subFilter != .all else {
                filteredProducts = products
                onDataUpdated?()
                return
            }
            
            filteredProducts = products.filter {
                ($0.title.uppercased().contains(subFilter.rawValue)) ||
                ($0.body_html.uppercased().contains(subFilter.rawValue)) ||
                ($0.vendor.uppercased().contains(subFilter.rawValue))
            }
            onDataUpdated?()
        }
}
