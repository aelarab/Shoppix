//
//  ShoppingCartService.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 06/11/2025.
//
//
//  ShoppingCartService.swift
//  Shoppix
//

import Foundation
import RxSwift

struct ShopifyErrorResponse: Codable {
    let errors: [String: [String]]?
}

class ShopifyCartService {
    static let shared = ShopifyCartService()
    private let disposeBag = DisposeBag()
    private init() {}

    func addToCart(product: Product, variant: Variant, userEmail: String) -> Observable<Bool> {
           return Observable.create { observer in
               let endpoint = "\(NetworkConstants.baseURL)/draft_orders.json"
               let headers = [
                   "X-Shopify-Access-Token": NetworkConstants.token,
                   "Content-Type": "application/json"
               ]
               
               let productImage = product.images.first?.src ?? ""
               
               let requestBody: [String: Any] = [
                   "draft_order": [
                       "email": userEmail,
                       "note_attributes": [
                           ["name": "product_image_\(variant.id)", "value": productImage]
                       ],
                       "line_items": [
                           [
                               "variant_id": variant.id,
                               "quantity": 1,
                               "title": product.title,
                               "price": variant.price
                           ]
                       ]
                   ]
               ]
               
               guard let url = URL(string: endpoint),
                     let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
                   observer.onNext(false)
                   observer.onCompleted()
                   return Disposables.create()
               }
               
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               request.httpBody = jsonData
               headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
               
               let task = URLSession.shared.dataTask(with: request) { data, response, error in
                   if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                       observer.onNext(true)
                   } else {
                       observer.onNext(false)
                   }
                   observer.onCompleted()
               }
               
               task.resume()
               return Disposables.create { task.cancel() }
           }
       }
       
    func getCart(userEmail: String) -> Observable<[DraftOrder]> {
        return Observable.create { observer in
            let endpoint = "\(NetworkConstants.baseURL)/draft_orders.json"
            let headers = [
                "X-Shopify-Access-Token": NetworkConstants.token,
                "Content-Type": "application/json"
            ]

            NetworkManager.requestGET(endpoint: endpoint, headers: headers) { (result: Result<DraftOrdersListResponse, Error>) in
                switch result {
                case .success(let response):
                    let userOrders = response.draft_orders.filter {
                        $0.email?.lowercased() == userEmail.lowercased()
                    }

                    var fullOrders: [DraftOrder] = []
                    let group = DispatchGroup()

                    for order in userOrders {
                        group.enter()
                        let detailEndpoint = "\(NetworkConstants.baseURL)/draft_orders/\(order.id).json"
                        NetworkManager.requestGET(endpoint: detailEndpoint, headers: headers) { (detailResult: Result<DraftOrderResponse, Error>) in
                            switch detailResult {
                            case .success(let detailResponse):
                                fullOrders.append(detailResponse.draft_order)
                            case .failure(let err):
                                print("❌ Failed to fetch order details: \(err.localizedDescription)")
                            }
                            group.leave()
                        }
                    }

                    group.notify(queue: .main) {
                        // Only emit after ALL details are fetched
                        observer.onNext(fullOrders)
                        observer.onCompleted()
                    }

                case .failure(let error):
                    print("❌ Failed to fetch cart list: \(error.localizedDescription)")
                    observer.onNext([])
                    observer.onCompleted()
                }
            }

            return Disposables.create()
        }
    }


       
       // Delete entire draft order (cart)
       func deleteCart(draftOrderId: String) -> Observable<Bool> {
           return Observable.create { observer in
               let endpoint = "\(NetworkConstants.baseURL)/draft_orders/\(draftOrderId).json"
               let headers = [
                   "X-Shopify-Access-Token": NetworkConstants.token,
                   "Content-Type": "application/json"
               ]
               
               NetworkManager.requestDELETE(endpoint: endpoint, headers: headers) {
                   (result: Result<Bool, Error>) in
                   switch result {
                   case .success:
                       observer.onNext(true)
                   case .failure(let error):
                       print("❌ Failed to delete cart: \(error.localizedDescription)")
                       observer.onNext(false)
                   }
                   observer.onCompleted()
               }
               
               return Disposables.create()
           }
       }
       
       // Update item quantity in cart
       func updateCartItem(draftOrderId: String, lineItems: [LineItemData]) -> Observable<Bool> {
           return Observable.create { observer in
               let endpoint = "\(NetworkConstants.baseURL)/draft_orders/\(draftOrderId).json"
               let headers = [
                   "X-Shopify-Access-Token": NetworkConstants.token,
                   "Content-Type": "application/json"
               ]
               
               let updateRequest = DraftOrderUpdateRequest(
                   draft_order: DraftOrderUpdateData(line_items: lineItems)
               )
               
               NetworkManager.requestPUT(endpoint: endpoint, body: updateRequest, headers: headers) {
                   (result: Result<DraftOrderResponse, Error>) in
                   switch result {
                   case .success:
                       observer.onNext(true)
                   case .failure(let error):
                       print("❌ Failed to update cart: \(error.localizedDescription)")
                       observer.onNext(false)
                   }
                   observer.onCompleted()
               }
               
               return Disposables.create()
           }
       }
   }
