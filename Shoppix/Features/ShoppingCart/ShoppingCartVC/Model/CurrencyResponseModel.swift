//
//  CurrencyResponseModel.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 08/11/2025.
//

import Foundation

struct CurrencyResponse: Codable {
    let data: [String: CurrencyRate]
}

struct CurrencyRate: Codable {
    let code: String
    let value: Double
}
