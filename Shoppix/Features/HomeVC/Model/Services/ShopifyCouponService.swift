//
//  ShopifyCouponService.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 10/11/2025.
//

import Foundation
import RxSwift

class ShopifyCouponService {
       //MARK: - Properties
    static let shared = ShopifyCouponService()
    private init() {}
    
    private let baseURL = NetworkConstants.baseURL
    private let token = NetworkConstants.token
    

    
    // MARK: - API Methods
    
    func getAllPriceRules(completion: @escaping (Result<[PriceRule], Error>) -> Void) {
            let endpoint = "\(baseURL)/price_rules.json"
            let headers = [
                "X-Shopify-Access-Token": token,
                "Content-Type": "application/json"
            ]
            
            print("🔍 DEBUG: Fetching price rules from: \(endpoint)")
            
            NetworkManager.requestGET(endpoint: endpoint, headers: headers) { (result: Result<PriceRulesResponse, Error>) in
                switch result {
                case .success(let response):
                    print("✅ DEBUG: Successfully fetched \(response.price_rules.count) price rules")
                    for rule in response.price_rules {
                        print("   - Price Rule: \(rule.title ?? "No title") (ID: \(rule.id))")
                    }
                    completion(.success(response.price_rules))
                case .failure(let error):
                    print("❌ DEBUG: Failed to fetch price rules: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    func getDiscountCodesForPriceRule(priceRuleId: Int, completion: @escaping (Result<[DiscountCode], Error>) -> Void) {
            let endpoint = "\(baseURL)/price_rules/\(priceRuleId)/discount_codes.json"
            let headers = [
                "X-Shopify-Access-Token": token,
                "Content-Type": "application/json"
            ]
            
            print("🔍 DEBUG: Fetching discount codes for price rule: \(priceRuleId)")
            
            NetworkManager.requestGET(endpoint: endpoint, headers: headers) { (result: Result<DiscountCodesResponse, Error>) in
                switch result {
                case .success(let response):
                    print("✅ DEBUG: Found \(response.discount_codes.count) discount codes for price rule \(priceRuleId)")
                    for code in response.discount_codes {
                        print("   - Discount Code: \(code.code)")
                    }
                    completion(.success(response.discount_codes))
                case .failure(let error):
                    print("❌ DEBUG: Failed to fetch discount codes for price rule \(priceRuleId): \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    
    func validateDiscountCode(_ code: String, completion: @escaping (Result<DiscountLookupResponse, Error>) -> Void) {
        let endpoint = "\(baseURL)/discount_codes/lookup.json?code=\(code)"
        let headers = [
            "X-Shopify-Access-Token": token,
            "Content-Type": "application/json"
        ]
        
        NetworkManager.requestGET(endpoint: endpoint, headers: headers, completion: completion)
    }
    
    // MARK: - Get All Active Coupons
    func getActiveCoupons(completion: @escaping (Result<[ShopifyCoupon], Error>) -> Void) {
            print("🔄 DEBUG: Starting to fetch active coupons...")
            
            getAllPriceRules { [weak self] result in
                switch result {
                case .success(let priceRules):
                    print("🔍 DEBUG: Found \(priceRules.count) total price rules")
                    
                    let activePriceRules = priceRules.filter { self?.isPriceRuleActive($0) == true }
                    print("✅ DEBUG: \(activePriceRules.count) price rules are active")
                    
                    if activePriceRules.isEmpty {
                        print("⚠️ DEBUG: No active price rules found. Check your Shopify admin.")
                    }
                    
                    self?.fetchDiscountCodesForPriceRules(activePriceRules, completion: completion)
                    
                case .failure(let error):
                    print("❌ DEBUG: Failed in getActiveCoupons: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    
    private func fetchDiscountCodesForPriceRules(
        _ priceRules: [PriceRule],
        completion: @escaping (Result<[ShopifyCoupon], Error>) -> Void
    ) {
        var allCoupons: [ShopifyCoupon] = []
        let group = DispatchGroup()
        
        for priceRule in priceRules {
            group.enter()
            
            getDiscountCodesForPriceRule(priceRuleId: priceRule.id) { result in
                switch result {
                case .success(let discountCodes):
                    for discountCode in discountCodes {
                        print("🎟️ DEBUG: Linking PriceRule '\(priceRule.title ?? "Untitled")' → DiscountCode '\(discountCode.code)'")
                        
                        let coupon = ShopifyCoupon(
                            code: discountCode.code, 
                            discountValue: priceRule.value ?? "0",
                            valueType: priceRule.value_type ?? "percentage",
                            priceRuleId: priceRule.id,
                            discountCodeId: discountCode.id,
                            title: priceRule.title
                        )
                        allCoupons.append(coupon)
                    }
                    
                case .failure(let error):
                    print("❌ Failed to get discount codes for price rule \(priceRule.id): \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(allCoupons))
        }
    }

    
    private func isPriceRuleActive(_ priceRule: PriceRule) -> Bool {
            print("🔍 DEBUG: Checking if price rule '\(priceRule.title ?? "No title")' is active...")
            
            guard let startsAt = priceRule.starts_at else {
                print("❌ DEBUG: Price rule has no start date")
                return false
            }
            
            let dateFormatter = ISO8601DateFormatter()
            let currentDate = Date()
            
            // Check if the coupon has started
            if let startDate = dateFormatter.date(from: startsAt) {
                if currentDate < startDate {
                    print("❌ DEBUG: Price rule hasn't started yet (starts at: \(startsAt))")
                    return false
                }
            } else {
                print("❌ DEBUG: Could not parse start date: \(startsAt)")
            }
            
            // Check if the coupon has ended
            if let endsAt = priceRule.ends_at {
                if let endDate = dateFormatter.date(from: endsAt) {
                    if currentDate > endDate {
                        print("❌ DEBUG: Price rule has ended (ended at: \(endsAt))")
                        return false
                    }
                } else {
                    print("❌ DEBUG: Could not parse end date: \(endsAt)")
                }
            }
            
            // Check usage limit
            if let usageLimit = priceRule.usage_limit, usageLimit <= 0 {
                print("❌ DEBUG: Price rule usage limit reached or zero")
                return false
            }
            
            print("✅ DEBUG: Price rule is active!")
            return true
        }
    // Add this to ShopifyCouponService
    func debugPriceRules() {
        let endpoint = "\(baseURL)/price_rules.json"
        let headers = [
            "X-Shopify-Access-Token": token,
            "Content-Type": "application/json"
        ]
        
        print("🔍 DEBUG: Testing price rules API directly...")
        
        NetworkManager.debugAPIResponse(url: endpoint, headers: headers)
    }
    
}
