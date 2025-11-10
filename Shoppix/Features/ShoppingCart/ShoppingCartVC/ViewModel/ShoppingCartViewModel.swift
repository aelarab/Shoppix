//
//  ShoppingCartViewModel.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 08/11/2025.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth

class ShoppingCartViewModel {
    // MARK: - Properties
    
    // inputs
    let refreshTrigger = PublishRelay<Void>()
    let deleteItemTrigger = PublishRelay<DraftOrderLineItem>()
    let updateQuantityTrigger = PublishRelay<(DraftOrderLineItem, Int)>()
    
    // Outputs
    let cartItems = BehaviorRelay<[DraftOrderLineItem]>(value: [])
    let totalPrice = BehaviorRelay<Double>(value: 0)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    let isEmpty = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()
    private var draftOrders: [DraftOrder] = []
    private let service = ShopifyCartService.shared
    
    init() {
        setupBindings()
    }
    
       //MARK: - Behaviour
    
    func isCartEmpty() -> Bool {
        return cartItems.value.isEmpty
    }
    
    private func setupBindings() {
            // Refresh
            refreshTrigger
                .subscribe(onNext: { [weak self] in
                    self?.loadCart()
                })
                .disposed(by: disposeBag)
            
            // Delete
            deleteItemTrigger
                .subscribe(onNext: { [weak self] item in
                    self?.deleteItem(item)
                })
                .disposed(by: disposeBag)
            
            // Update quantity
            updateQuantityTrigger
                .subscribe(onNext: { [weak self] (item, quantity) in
                    self?.updateItemQuantity(item, newQuantity: quantity)
                })
                .disposed(by: disposeBag)
        }
        
        // MARK: - Cart Logic
        func loadCart() {
            guard let userEmail = Auth.auth().currentUser?.email else {
                errorMessage.accept("Please sign in to view your cart.")
                isEmpty.accept(true)
                return
            }
            
            isLoading.accept(true)
            
            service.getCart(userEmail: userEmail)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] draftOrders in
                    guard let self = self else { return }
                    self.isLoading.accept(false)
                    self.draftOrders = draftOrders
                    
                    let items = draftOrders.flatMap { $0.line_items }
                    self.cartItems.accept(items)
                    self.isEmpty.accept(items.isEmpty)
                    
                    let total = items.reduce(0.0) { $0 + ((Double($1.price ?? "0") ?? 0) * Double($1.quantity)) }
                    self.totalPrice.accept(total)
                    
                }, onError: { [weak self] error in
                    self?.isLoading.accept(false)
                    self?.errorMessage.accept("Failed to load cart: \(error.localizedDescription)")
                })
                .disposed(by: disposeBag)
        }
        
        private func deleteItem(_ item: DraftOrderLineItem) {
            guard let draftOrder = draftOrders.first(where: { $0.line_items.contains(where: { $0.id == item.id }) }),
                  let itemId = item.id else {
                errorMessage.accept("Cannot find item to delete.")
                return
            }
            
            var updatedLineItems = draftOrder.line_items.filter { $0.id != itemId }
                .map {
                    LineItemData(variant_id: $0.variant_id ?? 0, quantity: $0.quantity, title: $0.title, price: $0.price)
                }
            
            if updatedLineItems.isEmpty {
                service.deleteCart(draftOrderId: "\(draftOrder.id)")
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] success in
                        if success { self?.loadCart() }
                        else { self?.errorMessage.accept("Failed to delete cart.") }
                    })
                    .disposed(by: disposeBag)
            } else {
                service.updateCartItem(draftOrderId: "\(draftOrder.id)", lineItems: updatedLineItems)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] success in
                        if success { self?.loadCart() }
                        else { self?.errorMessage.accept("Failed to remove item.") }
                    })
                    .disposed(by: disposeBag)
            }
        }
        
        private func updateItemQuantity(_ item: DraftOrderLineItem, newQuantity: Int) {
            guard let draftOrder = draftOrders.first(where: { $0.line_items.contains(where: { $0.id == item.id }) }),
                  let itemId = item.id else {
                errorMessage.accept("Cannot find item to update.")
                return
            }
            
            let updatedLineItems = draftOrder.line_items.map {
                LineItemData(
                    variant_id: $0.variant_id ?? 0,
                    quantity: $0.id == itemId ? newQuantity : $0.quantity,
                    title: $0.title,
                    price: $0.price
                )
            }
            
            service.updateCartItem(draftOrderId: "\(draftOrder.id)", lineItems: updatedLineItems)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] success in
                    if success { self?.loadCart() }
                    else { self?.errorMessage.accept("Failed to update item quantity.") }
                })
                .disposed(by: disposeBag)
        }
        
        func getImageUrl(for cartItem: DraftOrderLineItem) -> String? {
            guard let draftOrder = draftOrders.first(where: { $0.line_items.contains(where: { $0.id == cartItem.id }) }) else {
                return nil
            }
            if let variantId = cartItem.variant_id,
               let attr = draftOrder.note_attributes?.first(where: { $0.name == "product_image_\(variantId)" }) {
                return attr.value
            }
            return nil
        }
    
}
