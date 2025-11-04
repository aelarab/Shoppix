//
//  ProductModel.swift
//  SHOPPIX
//
//  Created by adham ragap on 30/10/2025.
//

import Foundation
struct ProductModel: Codable {
    let products: [Product]
}

struct Product: Codable {
    let id: Int
    let title: String
    let vendor: String
    let images: [ProductImage]
    let variants: [Variant]
    let body_html:String
    
}

struct ProductImage: Codable {
    let src: String
}

struct Variant: Codable {
    let price: String
    let id: Int
    let title: String
    let sku: String?
    let available: Bool?
    let inventory_quantity:Int
}
struct SingleProductModel: Codable {
    let product: Product
}
