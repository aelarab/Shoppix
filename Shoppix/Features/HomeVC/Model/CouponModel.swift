//
//  CouponModel.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 05/11/2025.
//

import Foundation
import UIKit


struct Coupon {
    var couponName: String
    var couponDiscount: Float
    var couponImage: UIImage
    var shopifyCode: String?
    var valueType: String?
    var priceRuleId: Int?
}
struct PriceRule: Codable {
    let id: Int
    let title: String?
    let value_type: String?
    let value: String?
    let allocation_method: String?
    let customer_selection: String?
    let starts_at: String?
    let ends_at: String?
    let usage_limit: Int?
}

struct PriceRulesResponse: Codable {
    let price_rules: [PriceRule]
}

struct DiscountCode: Codable {
    let id: Int
    let price_rule_id: Int
    let code: String
    let usage_count: Int?
}

struct DiscountCodesResponse: Codable {
    let discount_codes: [DiscountCode]
}

struct DiscountLookupResponse: Codable {
    let discount_code: DiscountCode?
}

// Shopify Coupon Model
struct ShopifyCoupon {
    let code: String
    let discountValue: String
    let valueType: String
    let priceRuleId: Int
    let discountCodeId: Int
    let title: String?
}
