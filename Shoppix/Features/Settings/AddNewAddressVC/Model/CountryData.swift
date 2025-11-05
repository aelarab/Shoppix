//
//  CountryData.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 04/11/2025.
//

import Foundation
struct CountryData: Decodable {
    let countries: [Country]
}

struct Country: Decodable {
    let name: String
    let cities: [String]
}
