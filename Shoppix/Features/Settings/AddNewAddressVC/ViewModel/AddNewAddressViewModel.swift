//
//  AddNewAddressViewModel.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 04/11/2025.
//

import Foundation

final class AddAddressViewModel {
    
    // MARK: - Properties
    var country: String = ""
    var city: String = ""
    var address: String = ""
    var phone: String = ""
    
    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Behaviour
    private func validateFields() -> Bool {
        guard !country.isEmpty else { onError?("Please select a country."); return false }
        guard !city.isEmpty else { onError?("Please select a city."); return false }
        guard !address.isEmpty else { onError?("Please enter an address."); return false }
        guard !phone.isEmpty else { onError?("Please enter a phone number."); return false }
        return true
    }
    
    // for saving address later
//    func saveAddress() {
//        guard validateFields() else { return }
//        
//        AddressService.shared.addAddress(
//            country: country,
//            city: city,
//            address: address,
//            phone: phone
//        )
//        onSuccess?()
//    }
}
