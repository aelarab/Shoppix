//
//  ShopifyConfig.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 29/10/2025.
//

import Foundation
    
struct ShopifyConfig {
    static var baseURL: String {
        return Bundle.main.infoDictionary?["SHOPIFY_BASE_URL"] as? String ?? ""
    }

    static var accessToken: String {
        return Bundle.main.infoDictionary?["SHOPIFY_ACCESS_TOKEN"] as? String ?? ""
    }

    static var apiKey: String {
        return Bundle.main.infoDictionary?["SHOPIFY_API_KEY"] as? String ?? ""
    }
}
