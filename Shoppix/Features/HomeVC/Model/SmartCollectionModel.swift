//
//  MainModel.swift
//  SHOPPIX
//
//  Created by adham ragap on 29/10/2025.
//

import Foundation
struct SmartCollectionModel: Codable {
    let smart_collections: [SmartCollection]
}

struct SmartCollection: Codable {
    let id: Int
    let title: String
    let handle: String
    let image: SmartImage?
}

struct SmartImage: Codable {
    let src: String
}
