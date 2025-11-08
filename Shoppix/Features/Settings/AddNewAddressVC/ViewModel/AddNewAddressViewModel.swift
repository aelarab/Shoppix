//
//  AddNewAddressViewModel.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 04/11/2025.
//

import Foundation
import RxSwift
import FirebaseAuth
import FirebaseFirestoreInternal

// AddNewAddressViewModel.swift
final class AddAddressViewModel {
    
    // MARK: - Properties
    var country: String = ""
    var city: String = ""
    var address: String = ""
    var phone: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var isDefault: Bool = false
    var customerId: Int? // Store customer ID here
    
    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Behaviour
    private func validateFields() -> Bool {
        guard !country.isEmpty else { onError?("Please select a country."); return false }
        guard !city.isEmpty else { onError?("Please select a city."); return false }
        guard !address.isEmpty else { onError?("Please enter an address."); return false }
        guard !phone.isEmpty else { onError?("Please enter a phone number."); return false }
        guard !firstName.isEmpty else { onError?("First name is missing."); return false }
        guard !lastName.isEmpty else { onError?("Last name is missing."); return false }
        guard customerId != nil else { onError?("Customer not found. Please login again."); return false }
        return true
    }
    
    func saveAddress() {
        guard validateFields() else { return }
        
        guard let customerId = customerId else {
            onError?("Customer not found. Please login again.")
            return
        }
        
        print("Attempting to create address for customer ID: \(customerId)")
        print("Using name: \(firstName) \(lastName)")
        
        let addressData = AddressData(
            address1: address,
            city: city,
            country: country,
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            isDefault: isDefault
        )
        
        AddressService.shared.createAddress(customerId: customerId, address: addressData) { [weak self] (result: Result<ShopifyAddress, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedAddress):
                    print("Successfully saved address with ID: \(savedAddress.id)")
                    self?.onSuccess?()
                case .failure(let error):
                    print("Error saving address: \(error)")
                    self?.onError?("Failed to save address: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Fetch User Name and Customer ID from Firebase
    func fetchUserData(completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching user data: \(error)")
                    completion(false)
                    return
                }

                guard let data = snapshot?.data() else {
                    print("No user data found")
                    completion(false)
                    return
                }

                // Fetch name
                if let firstName = data["firstName"] as? String,
                   let lastName = data["lastName"] as? String {
                    self?.firstName = firstName
                    self?.lastName = lastName
                    print("Retrieved name from Firebase: \(firstName) \(lastName)")
                } else {
                    self?.firstName = "Customer"
                    self?.lastName = "User"
                }

                // Fetch customer ID
                if let shopifyCustomerId = data["shopifyCustomerId"] as? Int {
                    self?.customerId = shopifyCustomerId
                    print("Retrieved customer ID from Firebase: \(shopifyCustomerId)")
                } else if let shopifyCustomerIdString = data["shopifyCustomerId"] as? String,
                          let shopifyCustomerId = Int(shopifyCustomerIdString) {
                    self?.customerId = shopifyCustomerId
                    print("Retrieved customer ID from Firebase: \(shopifyCustomerId)")
                } else {
                    print("No customer ID found in Firebase")
                }

                completion(self?.customerId != nil)
            }
        }
    }
}
