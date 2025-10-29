//
//  PriceRuleViewModel.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 29/10/2025.
//

import Foundation
class PriceRuleViewModel{
    
    var network:ApiProtocol
    
    init(network: ApiProtocol) {
        self.network = network
    }
    
    func getAllPriceRules(completionHandler: @escaping ([PriceRule]) -> Void){
        
        Api.get(endPoint: EndPoints.couponPriceRule) {(data: PriceRulesResponse?, error) in
            guard let responsData = data else{ return}
            completionHandler(responsData.price_rules )
        }
    }
    
    func addPriceRule(priceRule: PriceRule,completionHandler: @escaping (PriceRule) -> Void){
        
        let params: [String: Any] = [
            "price_rule":[
                "title": priceRule.title ?? "",
                "value_type": priceRule.valueType ?? "value_type",
                "value": priceRule.value ?? "",

                "starts_at": priceRule.startsAt ?? "",
                "ends_at": priceRule.endsAt ?? "",
                "usage_limit": priceRule.usageLimit ?? "",
                "customer_selection": "all",
                "target_type": "line_item",
                "target_selection": "all",
                "allocation_method": "across"
            ] as [String : Any]
        ]
        
        Api.post(endPoint: EndPoints.couponPriceRule, params: params) { (data: OnePriceRuleResponse?, error) in
            guard let responsData = data else{ return}
            completionHandler((responsData.price_rule))
            print(responsData.price_rule )
        }
    }

    func updatePriceRule(priceRule: PriceRule,completionHandler: @escaping (PriceRule) -> Void){
        
        let params: [String: Any] = [
            "price_rule":[
                "title": priceRule.title ?? "",
                "value_type": priceRule.valueType ?? "",
                "value": priceRule.value ?? "",

                "starts_at": priceRule.startsAt ?? "",
                "ends_at": priceRule.endsAt ?? "",
                "usage_limit": priceRule.usageLimit ?? "",
                "customer_selection": "all",
                "target_type": "line_item",
                "target_selection": "all",
                "allocation_method": "across"
            ] as [String : Any]
        ]
        Api.update(endPoint: EndPoints.editPriceRule(id: priceRule.id ?? 0), params: params) {  (data: OnePriceRuleResponse?, error)  in
            guard let responsData = data else{ return}
            
            completionHandler(responsData.price_rule)
            
            print(responsData.price_rule)
        }
    }
    
    func deletePriceRule(priceRule: PriceRule){
        Api.delete(endPoint: EndPoints.editPriceRule(id: priceRule.id ?? 0))
    }
}
