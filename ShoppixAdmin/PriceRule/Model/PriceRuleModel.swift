//
//  PriceRuleModel.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 29/10/2025.
//

import Foundation
struct OnePriceRuleResponse: Codable {
    let price_rule: PriceRule
}

struct PriceRulesResponse: Codable {
    let price_rules: [PriceRule]
}

// MARK: - PriceRule
struct PriceRule: Codable {
    
    var id: Int?
    var title: String?
    var usageLimit: Int?
    var value: String?
    var valueType: String?
    var allocationLimit: Int?
    var allocationMethod: String?
    var createdAt: String?
    var updatedAt: String?
    var customerSelection: String?
    var endsAt: String?
    var startsAt: String?
    var targetSelection: String?
    var targetType: String?

    private enum CodingKeys: String, CodingKey {
        
        case id = "id"
        
        case title = "title"
        case usageLimit = "usage_limit"
        case value = "value"
        case valueType = "value_type"
        case allocationLimit = "allocation_limit"
        
        case allocationMethod = "allocation_method"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case customerSelection = "customer_selection"
        case endsAt = "ends_at"
        case startsAt = "starts_at"
        case targetSelection = "target_selection"
        case targetType = "target_type"
    }
    
    
}
