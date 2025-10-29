//
//  Endpoints.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 25/10/2025.
//

import Foundation
enum EndPoints {
    
    case createProduct
    case createProductImg(id: Int)
    case createProductVariants(id: Int)
    case updateProduct(id: Int)
    
    case addProductToCustomCollection

    case couponPriceRule
    case discountCodes(id: Int)
    case singleDiscountCode(priceRuleId: Int,discountId: Int)
    case editPriceRule(id: Int)
    
    case inventorySet
    
    case createSmartCollection
    case editSmartCollection(id: Int)
    
    case createCustomCollection
    case editCustomCollection(id: Int)
    
    var path:String{
        switch self {
            
            case .createProduct:
                return "products.json"
            case .createProductImg(id: let productId):
                return "products/\(productId)/images.json"
            case .createProductVariants(id: let productId):
                return "products/\(productId)/variants.json"
            case .updateProduct(id: let productId):
                return "products/\(productId).json"
            
            case .addProductToCustomCollection:
                return "collects.json"
            
            case .couponPriceRule:
                return "price_rules.json"
            case .discountCodes(id: let priceRuleId):
                return "price_rules/\(priceRuleId)/discount_codes.json"
            case .singleDiscountCode(priceRuleId: let priceRuleId,discountId: let discountId):
                return "price_rules/\(priceRuleId)/discount_codes/\(discountId).json"
            case .editPriceRule(id: let priceRuleId):
                return "price_rules/\(priceRuleId).json"
        
        case .inventorySet:
                return "/inventory_levels/set.json"
            
            case .createSmartCollection:
                return "smart_collections.json"
            case .editSmartCollection(id: let smartCollectionId):
                return "smart_collections/\(smartCollectionId).json"
            
            case .createCustomCollection:
                return "custom_collections.json"
            case .editCustomCollection(id: let customCollectionId):
                return "custom_collections/\(customCollectionId).json"
            
        }
    }
    
}

