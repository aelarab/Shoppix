//
//  Collects.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 05/11/2025.
//

import Foundation
struct CollectsResponse: Codable {
    let collects: [Collect]
}

struct Collect: Codable {
    let id: Int
    let product_id: Int
}
