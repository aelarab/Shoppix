//
//  CurrencyService.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 08/11/2025.
//


import Foundation

import Foundation

final class CurrencyService {
    static let shared = CurrencyService()
    
    private let baseURL = "https://api.currencyapi.com/v3/latest"
    private let apiKey = "cur_live_3CU7B9NoOndsH4svnWSvbekfmdjnazi7O4Xnt11Q"
    
    private var usdToEgpRate: Double = 30.0
    private(set) var currentCurrency: String {
        didSet {
            UserDefaults.standard.set(currentCurrency, forKey: "selectedCurrency")
            fetchRates()
            NotificationCenter.default.post(name: .currencyDidChange, object: nil)
        }
    }
    
    private init() {
        currentCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "EGP"
        fetchRates()
    }
    
    // MARK: - API Fetch
    
    func fetchRates(completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: "\(baseURL)?apikey=\(apiKey)&base_currency=USD") else {
            print("Invalid URL")
            setDefaultRate()
            completion?(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                self.setDefaultRate()
                completion?(false)
                return
            }
            
            guard let data = data else {
                print("No data")
                self.setDefaultRate()
                completion?(false)
                return
            }
            
            do {
                let response = try JSONDecoder().decode(CurrencyResponse.self, from: data)
                if let egpRate = response.data["EGP"]?.value {
                    self.usdToEgpRate = egpRate
                    completion?(true)
                } else {
                    self.setDefaultRate()
                    completion?(false)
                }
            } catch {
                self.setDefaultRate()
                completion?(false)
            }
        }.resume()
    }
    
    // this function for adding a default value ie dolar = 30 gneeh
    private func setDefaultRate() {
        usdToEgpRate = 30.0
    }
        
    func convert(amount: Double, from sourceCurrency: String = "EGP", to targetCurrency: String) -> Double {
        if sourceCurrency == targetCurrency {
            return amount
        }
        if sourceCurrency == "EGP" && targetCurrency == "USD" {
            return amount / usdToEgpRate
        }
        if sourceCurrency == "USD" && targetCurrency == "EGP" {
            return amount * usdToEgpRate
        }
        return amount
    }
    
    func formatPrice(_ price: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        switch currency {
        case "EGP":
            formatter.currencySymbol = "EGP "
            return formatter.string(from: NSNumber(value: price)) ?? "EGP \(String(format: "%.2f", price))"
        case "USD":
            formatter.currencySymbol = "$"
            return formatter.string(from: NSNumber(value: price)) ?? "$\(String(format: "%.2f", price))"
        default:
            return "\(String(format: "%.2f", price)) \(currency)"
        }
    }
    
    func updateCurrency(_ newCurrency: String) {
        guard newCurrency == "EGP" || newCurrency == "USD" else {
            return
        }
        guard newCurrency != currentCurrency else { return }
        currentCurrency = newCurrency
    }
    
    func getAvailableCurrencies() -> [String] {
        return ["EGP", "USD"]
    }
    
    func getCurrentExchangeRate() -> Double {
        return usdToEgpRate
    }
}
