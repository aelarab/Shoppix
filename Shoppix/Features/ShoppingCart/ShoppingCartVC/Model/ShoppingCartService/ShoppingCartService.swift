//
//  ShoppingCartService.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 06/11/2025.
//

import Foundation
import RxSwift

class ShopifyCartService {
    static let shared = ShopifyCartService()
    private let disposeBag = DisposeBag()
    
    private init() {}
    
    func addToCart(product: Product, variant: Variant, userEmail: String) -> Observable<DraftOrderResponse> {
        let endpoint = "/draft_orders.json"
        let url = NetworkConstants.baseURL
        
        let draftOrderPayload: [String: Any] = [
            "draft_order": [
                "email": userEmail,
                "line_items": [
                    [
                        "variant_id": variant.id,
                        "quantity": 1
                    ]
                ]
            ]
        ]
        
        let headers = [
            "X-Shopify-Access-Token": Constant.adminApiAccessToken,
            "Content-Type": "application/json"
        ]
        
        return NetworkService.shared.post(
            url: url,
            endpoint: endpoint,
            parameters: draftOrderPayload,
            headers: headers
        )
    }
    
    func fetchCart(for email: String) -> Observable<[DraftOrder]> {
        let endpoint = "/draft_orders.json"
        let url = NetworkConstants.baseURL
        let headers = [
            "X-Shopify-Access-Token": Constant.adminApiAccessToken,
            "Content-Type": "application/json"
        ]
        
        return NetworkService.shared.get(
            url: url,
            endpoint: endpoint,
            parameters: nil,
            headers: headers
        )
        .map { (response: DraftOrdersResponse) in
            return response.draft_orders.filter { $0.email == email }
        }
    }
}
