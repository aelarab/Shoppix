//
//  SmartCollectionModel.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 25/10/2025.
//

import Foundation

struct AllSmartCollectionModel: Codable {
    var smart_collections: [SmartCollection]
}

struct SmartCollection: Codable {
    let id: Int
    let handle: String?
    let title: String
    let updated_at: String?
    let body_html: String?
    let sort_order: String
    let template_suffix: String?
    var productsCount: Int?  // <-- new

    let image: BrandImage?
}

struct BrandImage: Codable {
    let src: String?
    let alt: String?
    let width: Int?
    let height: Int?
    let created_at: String?
}

