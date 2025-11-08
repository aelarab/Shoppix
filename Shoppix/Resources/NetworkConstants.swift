//
//  NetworkConstants.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 06/11/2025.
//

import Foundation
struct NetworkConstants {
    static let baseURL = "https://iosr1g1.myshopify.com/admin/api/2025-07"
    static var token: String {
        ProcessInfo.processInfo.environment["SHOPIFY_ACCESS_TOKEN"] ?? ""
    }
}
