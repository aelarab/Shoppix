//
//  ProductCustomCollectionModel.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 25/10/2025.
//

import Foundation
struct ProductCustomCollectionModel: Codable {
    let collect: CustomCollection
}

// MARK: - ADDCollection
struct CustomCollection: Codable {
    let id, collection_id, product_id: Int
    let position: Int
    let sort_value: String

   
}
