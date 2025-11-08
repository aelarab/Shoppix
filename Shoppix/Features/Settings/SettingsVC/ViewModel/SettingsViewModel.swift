//
//  SettingsViewModel.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 04/11/2025.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseFirestore

final class SettingsViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    let defaultAddress = BehaviorRelay<ShopifyAddress?>(value: nil)
    var onCurrencyChanged: ((String) -> Void)?
    
    init() {
        CurrencyService.shared.currentCurrency
            .subscribe(onNext: { [weak self] currency in
                self?.onCurrencyChanged?(currency)
            })
            .disposed(by: disposeBag)
    }

    
    // MARK: - Behaviour
    func updateCurrency(to newCurrency: String) {
        CurrencyService.shared.updateCurrency(newCurrency)
    }
    
    func loadDefaultAddress() {
            
            fetchCustomerIdFromFirebase { [weak self] customerId in
                guard let customerId = customerId else {

                    return
                }
                
                AddressService.shared.getDefaultAddress(customerId: customerId) { result in
                    
                    switch result {
                    case .success(let address):
                        print("Settings - Loaded default address: \(address?.city ?? "No city")")
                        self?.defaultAddress.accept(address)
                    case .failure(let error):
                        print("Settings - Error loading default address: \(error)")

                    }
                }
            }
        }
        
        // MARK: - Firebase Customer ID Fetching
        private func fetchCustomerIdFromFirebase(completion: @escaping (Int?) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(nil)
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching customer ID from Firebase: \(error)")
                    completion(nil)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("No user data found in Firebase")
                    completion(nil)
                    return
                }
                
                // Try to get customer ID as Int or String
                if let customerId = data["shopifyCustomerId"] as? Int {
                    print("Settings - Found customer ID in Firebase: \(customerId)")
                    completion(customerId)
                } else if let customerIdString = data["shopifyCustomerId"] as? String,
                          let customerId = Int(customerIdString) {
                    print("Settings - Found customer ID in Firebase (string): \(customerId)")
                    completion(customerId)
                } else {
                    print("Settings - No customer ID found in Firebase data")
                    completion(nil)
                }
            }
        }
}
