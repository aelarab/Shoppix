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
            let coupons: [Coupon] = [
                Coupon(couponName: "25% OFF", couponDiscount: 25, couponImage: UIImage(named: "25coupon")!),
                Coupon(couponName: "50% OFF", couponDiscount: 50, couponImage: UIImage(named: "50coupon")!)
            ]
        delegete?.didFetchCoupons(coupons)
        }

    
}
