//
//  AddressModel.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 08/11/2025.
//

//
//  AddressModel.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 08/11/2025.
//

import Foundation

struct AddressData: Codable {
    let address1: String
    let city: String
    let province: String?
    let country: String
    let zip: String?
    let phone: String?
    let first_name: String
    let last_name: String
    let company: String?
    let isDefault: Bool?
    
    init(address1: String, city: String, country: String, phone: String, firstName: String, lastName: String, isDefault: Bool = false) {
        self.address1 = address1
        self.city = city
        self.province = city
        self.country = country
        self.zip = nil
        self.phone = phone
        self.first_name = firstName
        self.last_name = lastName
        self.company = nil
        self.isDefault = isDefault
    }
    
    enum CodingKeys: String, CodingKey {
        case address1, city, province, country, zip, phone
        case first_name, last_name, company
        case isDefault = "default"
    }
}

struct ShopifyAddress: Codable {
    let id: Int
    let address1: String
    let city: String
    let province: String?
    let country: String
    let zip: String?
    let phone: String?
    let first_name: String?
    let last_name: String?
    let isDefault: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, address1, city, province, country, zip, phone
        case first_name, last_name
        case isDefault = "default"
    }
}

struct CreateAddressRequest: Codable {
    let address: AddressData
}

struct CreateAddressResponse: Codable {
    let customer_address: ShopifyAddress
}

struct UpdateAddressRequest: Codable {
    let address: AddressData
}

// MARK: - Updated Customer Models
struct CustomerResponse: Codable {
    let customer: Customer?
}

struct Customer: Codable {
    let id: Int?
    let email: String?
    let first_name: String?
    let last_name: String?
    let addresses: [ShopifyAddress]?
    
    // Make all properties optional to handle partial responses
    enum CodingKeys: String, CodingKey {
        case id, email, addresses
        case first_name, last_name
    }
}

// MARK: - Alternative response model for addresses-only endpoint
struct CustomerAddressesResponse: Codable {
    let customer: CustomerAddresses?
}

struct CustomerAddresses: Codable {
    let addresses: [ShopifyAddress]?
}
