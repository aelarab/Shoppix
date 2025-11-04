//
//  SettingsViewModel.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 04/11/2025.
//

import Foundation

final class SettingsViewModel {
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let currencyKey = "selectedCurrency"
    
    var onCurrencyChanged: ((String) -> Void)?
    
    private(set) var currentCurrency: String {
        didSet {
            userDefaults.set(currentCurrency, forKey: currencyKey)
            onCurrencyChanged?(currentCurrency)
            NotificationCenter.default.post(
                name: .currencyDidChange,
                object: nil,
                userInfo: ["currency": currentCurrency]
            )
        }
    }
    
    // MARK: - Init
    init() {
        let savedCurrency = userDefaults.string(forKey: currencyKey)
        self.currentCurrency = savedCurrency ?? "EGP"
    }
    
    // MARK: - Behaviour
    func updateCurrency(to newCurrency: String) {
        guard newCurrency != currentCurrency else { return }
        currentCurrency = newCurrency
    }
}
