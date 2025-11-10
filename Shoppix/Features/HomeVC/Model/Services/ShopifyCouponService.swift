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
    

    
    // MARK: - Behaviour
    
    func getAllPriceRules(completion: @escaping (Result<[PriceRule], Error>) -> Void) {
            let endpoint = "\(baseURL)/price_rules.json"
            let headers = [
                "X-Shopify-Access-Token": token,
                "Content-Type": "application/json"
            ]
                        
            NetworkManager.requestGET(endpoint: endpoint, headers: headers) { (result: Result<PriceRulesResponse, Error>) in
                switch result {
                case .success(let response):
                    for rule in response.price_rules {
                        print("   - Price Rule: \(rule.title ?? "No title") (ID: \(rule.id))")
                    }
                    completion(.success(response.price_rules))
                case .failure(let error):
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
            
            NetworkManager.requestGET(endpoint: endpoint, headers: headers) { (result: Result<DiscountCodesResponse, Error>) in
                switch result {
                case .success(let response):

                    for code in response.discount_codes {
                        print("   - Discount Code: \(code.code)")
                    }
                    completion(.success(response.discount_codes))
                case .failure(let error):
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
    
    func getActiveCoupons(completion: @escaping (Result<[ShopifyCoupon], Error>) -> Void) {
            
            getAllPriceRules { [weak self] result in
                switch result {
                case .success(let priceRules):
                    
                    let activePriceRules = priceRules.filter { self?.isPriceRuleActive($0) == true }
                    
                    if activePriceRules.isEmpty {
                        print(" No active price rules found. Check your Shopify admin.")
                    }
                    
                    self?.fetchDiscountCodesForPriceRules(activePriceRules, completion: completion)
                    
                case .failure(let error):
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
                    print("Failed to get discount codes for price rule \(priceRule.id): \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(allCoupons))
        }
    }

    
    private func isPriceRuleActive(_ priceRule: PriceRule) -> Bool {

            
            guard let startsAt = priceRule.starts_at else {
                return false
            }
            
            let dateFormatter = ISO8601DateFormatter()
            let currentDate = Date()
            
            if let startDate = dateFormatter.date(from: startsAt) {
                if currentDate < startDate {
                    return false
                }
            } else {
            }
            
            if let endsAt = priceRule.ends_at {
                if let endDate = dateFormatter.date(from: endsAt) {
                    if currentDate > endDate {
                        return false
                    }
                } else {
                    print(" Could not parse end date: \(endsAt)")
                }
            }
            
            if let usageLimit = priceRule.usage_limit, usageLimit <= 0 {
                return false
            }
            
            return true
        }
    func debugPriceRules() {
        let endpoint = "\(baseURL)/price_rules.json"
        let headers = [
            "X-Shopify-Access-Token": token,
            "Content-Type": "application/json"
        ]
        
        NetworkManager.debugAPIResponse(url: endpoint, headers: headers)
    }
    
}
