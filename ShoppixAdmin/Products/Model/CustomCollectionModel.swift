//
//  CustomCollectionModel.swift
//  ShoppixAdmin
//
// Created by Ahmed Mohamed on 25/10/2025..
//

import Foundation

struct CustomCollectionModel: Codable {
    let custom_collection: NewCustomCollection
 
}

struct AllCustomCollectionModel: Codable {
    let custom_collections: [NewCustomCollection]
 
}
 

struct NewCustomCollection: Codable {
    let id: Int
    let title: String
     
}
