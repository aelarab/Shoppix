//
//  DraftOrderResponse.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 06/11/2025.
//

import Foundation

struct DraftOrderResponse: Codable {
    let draft_order: DraftOrder
}

struct DraftOrdersResponse: Codable {
    let draft_orders: [DraftOrder]
}

struct DraftOrder: Codable {
    let id: Int
    let email: String?
    let line_items: [LineItem]
}

struct LineItem: Codable {
    let id: Int?
    let title: String?
    let quantity: Int?
    let variant_id: Int?
}
