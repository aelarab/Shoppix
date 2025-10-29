//
//  Inventory.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 25/10/2025..
//

import Foundation

struct InventoryLevelResponse: Codable {

    var inventoryLevel: InventoryLevel?

    private enum CodingKeys: String, CodingKey {
        case inventoryLevel = "inventory_level"
    }

}

struct InventoryLevel: Codable {

    var inventoryItemId: Int?
    var locationId: Int?
    var available: Int?
    var updatedAt: String?
    var adminGraphqlApiId: String?

    private enum CodingKeys: String, CodingKey {
        case inventoryItemId = "inventory_item_id"
        case locationId = "location_id"
        case available = "available"
        case updatedAt = "updated_at"
        case adminGraphqlApiId = "admin_graphql_api_id"
    }

}
