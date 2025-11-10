//
//  AddressViewModel.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 08/11/2025.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseFirestore

class AddressViewModel {
    
    // MARK: - Outputs
    let defaultAddress = BehaviorRelay<ShopifyAddress?>(value: nil)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Public Methods
    func loadDefaultAddress() {
        isLoading.accept(true)
        
        fetchCustomerIdFromFirebase { [weak self] customerId in
            guard let customerId = customerId else {
                self?.isLoading.accept(false)
                self?.errorMessage.accept("Customer not found. Please login again.")
                return
            }
            
            AddressService.shared.getDefaultAddress(customerId: customerId) { result in
                self?.isLoading.accept(false)
                
                switch result {
                case .success(let address):
                    print("Loaded default address: \(address?.id ?? 0)")
                    self?.defaultAddress.accept(address)
                case .failure(let error):
                    print("Error loading default address: \(error)")
                    self?.errorMessage.accept("Failed to load address: \(error.localizedDescription)")
                }
            }
        }
    }
    
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
                    print("Loaded \(addresses.count) addresses")
                    let defaultAddress = addresses.first { $0.isDefault == true }
                    self?.defaultAddress.accept(defaultAddress)
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
                print("Found customer ID in Firebase: \(customerId)")
                completion(customerId)
            } else if let customerIdString = data["shopifyCustomerId"] as? String,
                      let customerId = Int(customerIdString) {
                print("Found customer ID in Firebase (string): \(customerId)")
                completion(customerId)
            } else {
                print("No customer ID found in Firebase data")
                completion(nil)
            }
        }
    }
}
