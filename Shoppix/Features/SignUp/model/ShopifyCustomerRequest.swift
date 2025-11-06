//
//  ShopifyCustomerRequest.swift
//  SHOPPIX
//
//  Created by adham ragap on 05/11/2025.
//

import Foundation
struct ShopifyCustomerRequest: Codable {
    let customer: CustomerData
}

struct CustomerData: Codable {
    let first_name: String
    let last_name: String
    let email: String
    let verified_email: Bool
}

struct ShopifyCustomerResponse: Codable {
    let customer: CustomerInfo
}

struct CustomerInfo: Codable {
    let id: Int
    let email: String
}
