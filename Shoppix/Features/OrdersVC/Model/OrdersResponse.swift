//
//  OrdersResponse.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 10/11/2025.
//

import Foundation

struct OrdersResponse: Codable {
    let orders: [Order]
}

struct Order: Codable {
    let id: Int
    let email: String?
    let created_at: String?
    let updated_at: String?
    let number: Int?
    let order_number: Int? 
    let total_price: String?
    let subtotal_price: String?
    let total_tax: String?
    let currency: String?
    let financial_status: String?
    let fulfillment_status: String?
    let line_items: [OrderLineItem]
    let shipping_address: ShippingAddress?
    let customer: Customer?
    let note: String?
    let phone: String?
}

struct OrderLineItem: Codable {
    let id: Int
    let variant_id: Int?
    let product_id: Int?
    let title: String
    let quantity: Int
    let price: String
    let sku: String?
    let variant_title: String?
    let vendor: String?
    let requires_shipping: Bool?
    let taxable: Bool?
    let gift_card: Bool?
    let grams: Int?
}

struct ShippingAddress: Codable {
    let first_name: String?
    let last_name: String?
    let address1: String?
    let address2: String?
    let city: String?
    let province: String?
    let country: String?
    let zip: String?
    let phone: String?
}

