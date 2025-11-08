//
//  CurrencyService.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 08/11/2025.
//


import RxSwift
import RxCocoa
import Foundation

final class CurrencyService {
    static let shared = CurrencyService()
    
    private let baseURL = "https://api.currencyapi.com/v3/latest"
    private let apiKey = "cur_live_3CU7B9NoOndsH4svnWSvbekfmdjnazi7O4Xnt11Q"
    
    private var usdToEgpRate: Double = 30.0 // Default fallback rate
    private let disposeBag = DisposeBag()
    
    let ratesReady = BehaviorRelay<Bool>(value: false)
    let currentCurrency = BehaviorRelay<String>(value: UserDefaults.standard.string(forKey: "selectedCurrency") ?? "EGP")
    
    private init() {
        // Load saved currency on init
        if let savedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") {
            currentCurrency.accept(savedCurrency)
        }
        
        // Fetch rates when service is initialized
        fetchRates()
        
        // Observe currency changes
        currentCurrency
            .skip(1) // Skip initial value
            .subscribe(onNext: { [weak self] newCurrency in
                UserDefaults.standard.set(newCurrency, forKey: "selectedCurrency")
                self?.fetchRates()
                // Notify the app about currency change
                NotificationCenter.default.post(name: .currencyDidChange, object: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchRates() {
        guard let url = URL(string: "\(baseURL)?apikey=\(apiKey)&base_currency=USD") else {
            print("❌ Invalid URL for currency API")
            setDefaultRate()
            return
        }
        
        print("🔄 Fetching USD to EGP exchange rate")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ Currency API error: \(error.localizedDescription)")
                self?.setDefaultRate()
                return
            }
            
            guard let data = data else {
                print("❌ No data from currency API")
                self?.setDefaultRate()
                return
            }
            
            do {
                let response = try JSONDecoder().decode(CurrencyResponse.self, from: data)
                if let egpRate = response.data["EGP"]?.value {
                    self?.usdToEgpRate = egpRate
                    print("✅ USD to EGP rate fetched successfully: \(egpRate)")
                    self?.ratesReady.accept(true)
                } else {
                    print("❌ EGP rate not found in API response")
                    self?.setDefaultRate()
                }
            } catch {
                print("❌ Currency API decoding error: \(error)")
                self?.setDefaultRate()
            }
        }.resume()
    }
    
    private func setDefaultRate() {
        // Set default rate if API fails
        usdToEgpRate = 30.0
        ratesReady.accept(true)
        print("⚠️ Using default USD to EGP rate: 30.0")
    }
    
    func convert(amount: Double, from sourceCurrency: String = "EGP", to targetCurrency: String) -> Double {
        // If same currency, return original amount
        if sourceCurrency == targetCurrency {
            return amount
        }
        
        // Convert from EGP to USD
        if sourceCurrency == "EGP" && targetCurrency == "USD" {
            return amount / usdToEgpRate
        }
        
        // Convert from USD to EGP
        if sourceCurrency == "USD" && targetCurrency == "EGP" {
            return amount * usdToEgpRate
        }
        
        print("⚠️ Unsupported currency conversion: \(sourceCurrency) to \(targetCurrency)")
        return amount
    }
    
    func formatPrice(_ price: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        // Custom formatting for EGP and USD only
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
        // Only allow EGP or USD
        guard newCurrency == "EGP" || newCurrency == "USD" else {
            print("❌ Unsupported currency: \(newCurrency). Only EGP and USD are supported.")
            return
        }
        
        guard newCurrency != currentCurrency.value else { return }
        
        currentCurrency.accept(newCurrency)
        print("🔄 Currency updated to: \(newCurrency)")
    }
    
    // Helper method to get available currencies
    func getAvailableCurrencies() -> [String] {
        return ["EGP", "USD"]
    }
    
    // Helper method to get current exchange rate
    func getCurrentExchangeRate() -> Double {
        return usdToEgpRate
    }
}
