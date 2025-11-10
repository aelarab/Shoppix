//
//  PlaceOrderViewModel.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 09/11/2025.
//

import Foundation
import FirebaseAuth
import RxSwift

import Foundation
import FirebaseAuth
import RxSwift

final class PlaceOrderViewModel {
    
    var selectedPaymentMethod: String?
    var totalAmountString: String?
    private let orderService = OrderService.shared
    private let cartService = ShopifyCartService.shared
    private let disposeBag = DisposeBag()
    
    func loadCartAndPlaceOrder(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            completion(.failure(NSError(domain: "", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "User email not found"])))
            return
        }
        
        cartService.getCart(userEmail: userEmail)
            .subscribe(onNext: { [weak self] draftOrders in
                guard let self = self else { return }
                guard let draftOrder = draftOrders.first else {
                    completion(.failure(NSError(domain: "", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Cart is empty"])))
                    return
                }
                
                let lineItems = draftOrder.line_items.map {
                    [
                        "variant_id": $0.variant_id ?? 0,
                        "quantity": $0.quantity ?? 1
                        // no need to include price here since Shopify will use transaction amount
                    ]
                }
                
                self.placeOrder(
                    email: userEmail,
                    draftOrderId: "\(draftOrder.id)",
                    lineItems: lineItems,
                    completion: completion
                )
            }, onError: { error in
                completion(.failure(error))
            })
            .disposed(by: disposeBag)
    }
    
    private func placeOrder(
        email: String,
        draftOrderId: String,
        lineItems: [[String: Any]],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let payment = selectedPaymentMethod else {
            completion(.failure(NSError(domain: "", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No payment method selected"])))
            return
        }

        guard let address = ChooseAddressService.shared.getSelectedAddress() else {
            completion(.failure(NSError(domain: "", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Shipping address missing"])))
            return
        }

        // Use the Apple Pay total passed from VC
        let totalAmount = totalAmountString ?? "0.00"

        orderService.createOrder(
            email: email,
            lineItems: lineItems,
            shippingAddress: address,
            paymentMethod: payment,
            totalAmount: totalAmount
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.cartService.deleteCart(draftOrderId: draftOrderId)
                    .subscribe(onNext: { success in
                        if success { print("🗑️ Cart cleared successfully") }
                        completion(.success(()))
                    }, onError: { error in
                        completion(.failure(error))
                    })
                    .disposed(by: self.disposeBag)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

