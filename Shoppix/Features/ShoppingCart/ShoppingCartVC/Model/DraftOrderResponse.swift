//
//  DraftOrderResponse.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 06/11/2025.
//

import Foundation

struct DraftOrderRequest: Codable {
    let draft_order: DraftOrderDataRequest
}

struct DraftOrderDataRequest: Codable {
    let email: String
    let note: String?
    let line_items: [DraftOrderLineItemRequest]

    enum CodingKeys: String, CodingKey {
        case email
        case note
        case line_items
    }
}

struct DraftOrderLineItemRequest: Codable {
    let variantId: Int
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case variantId = "variant_id"
        case quantity
    }
}

// MARK: - RESPONSE MODELS

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
