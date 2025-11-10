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
    private(set) var selectedPaymentIndex: IndexPath? = nil
    
    private(set) var selectedPayment: String? = nil
    
    // MARK: - Methods
    func selectPayment(at indexPath: IndexPath) {
        if selectedPaymentIndex == indexPath {
            selectedPaymentIndex = nil
            selectedPayment = nil
        } else {
            selectedPaymentIndex = indexPath
            selectedPayment = paymentOptions[indexPath.section][indexPath.row]
        }
    }

    
    func isSelected(at indexPath: IndexPath) -> Bool {
        return selectedPaymentIndex == indexPath
    }
    
    func selectedPaymentName() -> String? {
        guard let index = selectedPaymentIndex else { return nil }
        return paymentOptions[index.section][index.row]
    }
    
    func isPaymentSelected() -> Bool {
        return selectedPayment != nil
    }
}
