//
//  ChooseAddressViewModel.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 08/11/2025.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseFirestore

final class ChooseAddressViewModel {
    
    // MARK: - Outputs
    let addresses = BehaviorRelay<[ShopifyAddress]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Public Methods
    func loadAllAddresses() {
        isLoading.accept(true)
        
        fetchCustomerIdFromFirebase { [weak self] customerId in
            guard let customerId = customerId else {
                self?.isLoading.accept(false)
                self?.errorMessage.accept("Customer not found. Please login again.")
                return
            }
            
            AddressService.shared.getCustomerAddresses(customerId: customerId) { result in
                self?.isLoading.accept(false)
                
                switch result {
                case .success(let addresses):
                    print("Loaded \(addresses.count) addresses for selection")
                    self?.addresses.accept(addresses)
                case .failure(let error):
                    print("Error loading addresses: \(error)")
                    self?.errorMessage.accept("Failed to load addresses: \(error.localizedDescription)")
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
                print("ChooseAddress - Found customer ID in Firebase: \(customerId)")
                completion(customerId)
            } else if let customerIdString = data["shopifyCustomerId"] as? String,
                      let customerId = Int(customerIdString) {
                print("ChooseAddress - Found customer ID in Firebase (string): \(customerId)")
                completion(customerId)
            } else {
                print("ChooseAddress - No customer ID found in Firebase data")
                completion(nil)
            }
        }
    }
}
