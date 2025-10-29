//
//  ProductsResponse.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 25/10/2025.
//

import Foundation


struct ProductsResponse: Codable {
    var products: [Product]?
}

struct ProductInfoResponse: Codable {
    var product: Product?
}

// MARK: - Product
struct Product: Codable {

    var id: Int?
    var title: String?
    var bodyHtml: String?
    var vendor: String?
    var productType: String?
    var createdAt: String?
    var handle: String?
    var updatedAt: String?
    var publishedAt: String?
    var status: String?
    var publishedScope: String?
    var tags: String?
    var adminGraphqlApiId: String?
    var variants: [Variants]?
    var options: [Options]?
    var images: [Image]?
    var image: Image?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case bodyHtml = "body_html"
        case vendor = "vendor"
        case productType = "product_type"
        case createdAt = "created_at"
        case handle = "handle"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case status = "status"
        case publishedScope = "published_scope"
        case tags = "tags"
        case adminGraphqlApiId = "admin_graphql_api_id"
        case variants = "variants"
        case options = "options"
        case images = "images"
        case image = "image"
    }
}

// MARK: - Image
struct Image: Codable {
    
    var id: Int?
    var productId: Int?
    var position: Int?
    var createdAt: String?
    var updatedAt: String?
    var alt: String?
    var width: Int?
    var height: Int?
    var src: String?
    //var variantIds: [Any]
    var adminGraphqlApiId: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case productId = "product_id"
        case position = "position"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case alt = "alt"
        case width = "width"
        case height = "height"
        case src = "src"
        case adminGraphqlApiId = "admin_graphql_api_id"
    }
}

// MARK: - Variant

struct Variants: Codable {

    var id: Int?
    var productId: Int?
    var title: String?
    var price: String?
    var sku: String?
    var position: Int?
    var inventoryPolicy: String?
    var compareAtPrice: String?
    var fulfillmentService: String?
    var inventoryManagement: String?
    var option1: String?
    var option2: String?
    var option3: String?
    var createdAt: String?
    var updatedAt: String?
    var taxable: Bool?
    var barcode: String?
    var grams: Int?
    var imageId: String?
    var weight: Int?
    var weightUnit: String?
    var inventoryItemId: Int?
    var inventoryQuantity: Int?
    var oldInventoryQuantity: Int?
    var requiresShipping: Bool?
    var adminGraphqlApiId: String?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case productId = "product_id"
        case title = "title"
        case price = "price"
        case sku = "sku"
        case position = "position"
        case inventoryPolicy = "inventory_policy"
        case compareAtPrice = "compare_at_price"
        case fulfillmentService = "fulfillment_service"
        case inventoryManagement = "inventory_management"
        case option1 = "option1"
        case option2 = "option2"
        case option3 = "option3"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case taxable = "taxable"
        case barcode = "barcode"
        case grams = "grams"
        case imageId = "image_id"
        case weight = "weight"
        case weightUnit = "weight_unit"
        case inventoryItemId = "inventory_item_id"
        case inventoryQuantity = "inventory_quantity"
        case oldInventoryQuantity = "old_inventory_quantity"
        case requiresShipping = "requires_shipping"
        case adminGraphqlApiId = "admin_graphql_api_id"
    }

}

struct Options: Codable {

    var id: Int?
    var productId: Int?
    var name: String?
    var position: Int?
    var values: [String]?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case productId = "product_id"
        case name = "name"
        case position = "position"
        case values = "values"
    }
}
