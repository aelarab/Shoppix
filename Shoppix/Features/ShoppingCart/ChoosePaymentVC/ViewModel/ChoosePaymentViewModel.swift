//
//  ChoosePaymentViewModel.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 09/11/2025.
//

import Foundation
final class ChoosePaymentViewModel {
    
    // MARK: - Properties
    let paymentSections = ["Online Payments", "More Payment Options"]
    let paymentOptions = [
        ["Apple Pay"],
        ["Cash on Delivery"]
    ]
    
    private(set) var selectedPayment: String? = nil
    
    // MARK: - Methods
    func selectPayment(at indexPath: IndexPath) {
        selectedPayment = paymentOptions[indexPath.section][indexPath.row]
    }
    
    func isPaymentSelected() -> Bool {
        return selectedPayment != nil
    }
}
