//
//  DiscountsViewModel.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 29/10/2025.
//

import Foundation

class DiscountsViewModel{
    
    func getAllDiscountCoupons(priceRule:PriceRule, completionHandler: @escaping ([DiscountCode]) -> Void){

        Api.get(endPoint: EndPoints.discountCodes(id: priceRule.id ?? 0)) {(data: DiscountCodesResponse?, error) in
            guard let responsData = data else{ return}
            completionHandler(responsData.discountCodes)
        }
        
    }
    
    func addDiscountCode(discountCode:DiscountCode ,priceRule:PriceRule, completionHandler: @escaping (DiscountCode) -> Void){
        
        let params: [String: Any] = [
            "discount_code":[
                "code": discountCode.code
                ]
        ]
        
        Api.post(endPoint: EndPoints.discountCodes(id: priceRule.id ?? 0), params: params) {(data: CouponDiscountCodeModel?, error) in
            guard let responsData = data else{ return}
            completionHandler(responsData.discountCode)
          
        }
    }
    
    func updateDiscountCode(discountCode:DiscountCode ,priceRule:PriceRule, completionHandler: @escaping (DiscountCode) -> Void){
        
        let params: [String: Any] = [
            "discount_code":[
                "id": discountCode.id ?? 3,
                "code": discountCode.code ?? "10OFF"
                ]
        ]
                
        Api.update(endPoint: EndPoints.singleDiscountCode(priceRuleId: priceRule.id ?? 0, discountId: discountCode.id ?? 0), params: params) {(data: CouponDiscountCodeModel?, error) in
            guard let responsData = data else{ return}
            completionHandler(responsData.discountCode)
        
        }
        
        
    }
    
    func deleteDiscountCode(discountCode:DiscountCode ,priceRule:PriceRule){
        
        Api.delete(endPoint: EndPoints.singleDiscountCode(priceRuleId: priceRule.id ?? 0, discountId: discountCode.id ?? 0))
    }
}
