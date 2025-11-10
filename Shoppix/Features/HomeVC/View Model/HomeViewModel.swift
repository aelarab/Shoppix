//
//  HomeViewModel.swift
//  SHOPPIX
//
//  Created by adham ragap on 29/10/2025.
//

import Foundation
import UIKit
protocol SendProuctDelegete{
    func sendData(smartCollectionModel:SmartCollectionModel?)
    func didFetchCoupons(_ coupons: [Coupon])
    func didFailToFetchCoupons(with error: Error)
}
class HomeViewModel {
    var delegete:SendProuctDelegete!
    init(delegete:SendProuctDelegete){
        self.delegete = delegete
    }
    


    
    
    func getDataFromServer(){
        let shopifyToken = ProcessInfo.processInfo.environment["SHOPIFY_ACCESS_TOKEN"] ?? ""
        NetworkManager.getData(url: "https://iosr1g1.myshopify.com/admin/api/2025-07/smart_collections.json", headers: [
            "X-Shopify-Access-Token":shopifyToken,
            "Content-Type":"application/json"
                
        ]) { [weak self]  (smartCollectionModel:SmartCollectionModel?, error) in
            if error == nil {
                guard let smartCollection = smartCollectionModel else {
                    return
                }
                self?.delegete?.sendData(smartCollectionModel: smartCollection)
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
    
    func getCoupons() {
        print("🔄 DEBUG: Getting coupons...")
        
        // First, try Shopify
        ShopifyCouponService.shared.getActiveCoupons { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let shopifyCoupons):
                    if shopifyCoupons.isEmpty {
                        print("⚠️ DEBUG: No Shopify coupons found, using local coupons")
                        self?.getLocalCoupons()
                    } else {
                        print("✅ DEBUG: Found \(shopifyCoupons.count) Shopify coupons")
                        let coupons = self?.convertToAppCoupons(shopifyCoupons) ?? []
                        self?.delegete?.didFetchCoupons(coupons)
                    }
                    
                case .failure(let error):
                    print("❌ DEBUG: Shopify coupons failed, using local coupons: \(error.localizedDescription)")
                    self?.getLocalCoupons()
                }
            }
        }
    }

    private func getLocalCoupons() {
        let coupons: [Coupon] = [
            Coupon(
                couponName: "WELCOME25",
                couponDiscount: 25,
                couponImage: UIImage(named: "25coupon") ?? UIImage(named: "discount")!,
                shopifyCode: "WELCOME25",
                valueType: "percentage",
                priceRuleId: nil
            ),
            Coupon(
                couponName: "SAVE50",
                couponDiscount: 50,
                couponImage: UIImage(named: "50coupon") ?? UIImage(named: "discount")!,
                shopifyCode: "SAVE50",
                valueType: "percentage",
                priceRuleId: nil
            ),
            Coupon(
                couponName: "SUMMER10",
                couponDiscount: 10,
                couponImage: UIImage(named: "10coupon") ?? UIImage(named: "discount")!,
                shopifyCode: "SUMMER10",
                valueType: "percentage",
                priceRuleId: nil
            )
        ]
        
        // Make sure we have the images - add fallbacks
        print("✅ DEBUG: Loading \(coupons.count) local coupons")
        delegete?.didFetchCoupons(coupons)
    }
        
        private func convertToAppCoupons(_ shopifyCoupons: [ShopifyCoupon]) -> [Coupon] {
            return shopifyCoupons.map { shopifyCoupon in
                let discountValue = Float(shopifyCoupon.discountValue) ?? 0
                let couponName = shopifyCoupon.title ?? shopifyCoupon.code
                
                // Choose image based on discount value
                let image: UIImage
                if discountValue >= 50 {
                    image = UIImage(named: "50coupon") ?? UIImage(named: "discount")!
                } else if discountValue >= 25 {
                    image = UIImage(named: "25coupon") ?? UIImage(named: "discount")!
                } else if discountValue >= 10 {
                    image = UIImage(named: "10coupon") ?? UIImage(named: "discount")!
                } else {
                    image = UIImage(named: "discount") ?? UIImage()
                }
                
                return Coupon(
                    couponName: couponName,
                    couponDiscount: discountValue,
                    couponImage: image,
                    shopifyCode: shopifyCoupon.code,
                    valueType: shopifyCoupon.valueType,
                    priceRuleId: shopifyCoupon.priceRuleId
                )
            }
        }
    
}
