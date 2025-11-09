//
//  AddressService.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 09/11/2025.
//

import Foundation
class ChooseAddressService {
    
    static let shared = ChooseAddressService()
       private init() {}

       private let key = "selectedShippingAddress"

       func saveSelectedAddress(_ address: ShopifyAddress) {
           let addressDict: [String: Any] = [
               "id": address.id,
               "address1": address.address1,
               "city": address.city,
               "country": address.country,
               "phone": address.phone ?? "",
               "first_name": address.first_name ?? "",
               "last_name": address.last_name ?? ""
           ]
           UserDefaults.standard.set(addressDict, forKey: key)
           UserDefaults.standard.synchronize()
           print("💾 Saved selected shipping address: \(address.address1), \(address.city)")
       }

       func getSelectedAddress() -> [String: Any]? {
           return UserDefaults.standard.dictionary(forKey: key)
       }

       func clearSelectedAddress() {
           UserDefaults.standard.removeObject(forKey: key)
       }
   }
