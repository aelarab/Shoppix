//
//  CustomCollectionModel.swift
//  ShoppixAdmin
//
// Created by Ahmed Mohamed on 25/10/2025..
//

import Foundation


struct AllCustomCollectionModel: Codable {
    var custom_collections: [NewCustomCollection]
 
}
 

struct NewCustomCollection: Codable {
    let id: Int
    let title: String
    var productsCount: Int?  // <-- new

}

