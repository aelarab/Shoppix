//
//  DraftOrderResponse.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 06/11/2025.
//

//
//  DraftOrderResponse.swift
//  Shoppix
//

import Foundation

struct DraftOrdersListResponse: Codable {
    let draft_orders: [DraftOrder]
}

struct DraftOrderResponse: Codable {
    let draft_order: DraftOrder
}

struct DraftOrder: Codable {
    let id: Int
    let email: String?
    let line_items: [DraftOrderLineItem]
    let total_price: String?
    let currency: String?
    let note: String?
    let status: String?
    let note_attributes: [Property]?
}

// line items
struct DraftOrderLineItem: Codable {
    let id: Int?
    let variant_id: Int?
    let product_id: Int?
    let quantity: Int
    let title: String?
    let price: String?
    let properties: [Property]?
}

struct Property: Codable {
    let name: String?
    let value: String?
}

struct DraftOrderRequest: Codable {
    let draft_order: DraftOrderData
}

struct DraftOrderData: Codable {
    let email: String
    let line_items: [LineItemData]
}

struct LineItemData: Codable {
    let variant_id: Int
    let quantity: Int
    let title: String?
    let price: String?
}

struct DraftOrderUpdateRequest: Codable {
    let draft_order: DraftOrderUpdateData
}

struct DraftOrderUpdateData: Codable {
    let line_items: [LineItemData]
}
