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

    // Add Product to Cart (creates a draft order)
    func addToCart(product: Product, variant: Variant, userEmail: String) -> Observable<DraftOrderResponse> {
        return Observable.create { observer in
            let endpoint = "\(NetworkConstants.baseURL)/draft_orders.json"
            let headers = [
                "X-Shopify-Access-Token": NetworkConstants.token,
                "Content-Type": "application/json"
            ]

            let payload = DraftOrderRequest(
                draft_order: DraftOrderDataRequest(
                    email: userEmail,
                    note: nil,
                    line_items: [
                        DraftOrderLineItemRequest(variantId: variant.id, quantity: 1)
                    ]
                )
            )

            NetworkManager.requestPOST(endpoint: endpoint, body: payload, headers: headers) { (result: Result<DraftOrderResponse, Error>) in
                switch result {
                case .success(let response):
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }
    }

    // Fetch all draft orders then filter by user email
    func fetchCart(for email: String) -> Observable<[DraftOrder]> {
        return Observable.create { observer in
            let endpoint = "\(NetworkConstants.baseURL)/draft_orders.json"
            let headers = [
                "X-Shopify-Access-Token": NetworkConstants.token,
                "Content-Type": "application/json"
            ]

            NetworkManager.requestGET(endpoint: endpoint, headers: headers) { (result: Result<DraftOrdersResponse, Error>) in
                switch result {
                case .success(let response):
                    let userOrders = response.draft_orders.filter { $0.email == email }
                    observer.onNext(userOrders)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }
    }
}
