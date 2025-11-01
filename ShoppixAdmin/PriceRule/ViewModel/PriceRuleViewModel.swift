//
//  PriceRuleViewModel.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 29/10/2025.
//

import Foundation
class PriceRuleViewModel{
    
    var bindPriceRulesViewModelToController : (() -> Void)?
    var allPriceRules : [PriceRule] = []
    
    func getAllPriceRules(){
        
        Api.get(endPoint: EndPoints.couponPriceRule) { [weak self] (data : PriceRulesResponse? , error ) in
            guard let rules = data?.price_rules else{ return}
            self?.allPriceRules = rules
            self?.bindPriceRulesViewModelToController?()
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
