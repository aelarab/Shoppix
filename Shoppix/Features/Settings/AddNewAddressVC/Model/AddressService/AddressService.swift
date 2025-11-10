//
//  AddressService.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 04/11/2025.
//

import Foundation
import RxSwift

final class AddressService {
    static let shared = AddressService()
    private init() {}
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Get Customer Addresses
    func getCustomerAddresses(customerId: Int, completion: @escaping (Result<[ShopifyAddress], Error>) -> Void) {
        let endpoint = "\(NetworkConstants.baseURL)/customers/\(customerId).json?fields=addresses"
        let headers = [
            "X-Shopify-Access-Token": NetworkConstants.token,
            "Content-Type": "application/json"
        ]
        
        NetworkManager.requestGET(endpoint: endpoint, headers: headers) { (result: Result<CustomerResponse, Error>) in
            switch result {
            case .success(let response):
                let addresses = response.customer?.addresses ?? []
                completion(.success(addresses))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
<<<<<<< HEAD
    // MARK: - Create
//    func addAddress(country: String, city: String, address: String, phone: String, isDefault: Bool = false) {
//        let entity = AddressEntity(context: context)
//        entity.id = UUID().uuidString
//        entity.country = country
//        entity.city = city
//        entity.address = address
//        entity.phone = phone
//        entity.isDefault = isDefault
//        entity.createdAt = Date()
//
//        saveContext()
//    }
    
    // MARK: - Fetch
//    func fetchAddresses() -> [AddressEntity] {
//        let request: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
//        return (try? context.fetch(request)) ?? []
//    }
    
    // MARK: - Delete
//    func deleteAddress(_ address: AddressEntity) {
//        context.delete(address)
//        saveContext()
//    }
    
//    private func saveContext() {
//        if context.hasChanges {
//            try? context.save()
//        }
//    }
=======
    // MARK: - Create New Address
    func createAddress(customerId: Int, address: AddressData, completion: @escaping (Result<ShopifyAddress, Error>) -> Void) {
        let endpoint = "\(NetworkConstants.baseURL)/customers/\(customerId)/addresses.json"
        let headers = [
            "X-Shopify-Access-Token": NetworkConstants.token,
            "Content-Type": "application/json"
        ]
        
        let request = CreateAddressRequest(address: address)
        
        NetworkManager.requestPOST(endpoint: endpoint, body: request, headers: headers) { (result: Result<CreateAddressResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.customer_address))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Update Address
    func updateAddress(customerId: Int, addressId: Int, address: AddressData, completion: @escaping (Result<ShopifyAddress, Error>) -> Void) {
        let endpoint = "\(NetworkConstants.baseURL)/customers/\(customerId)/addresses/\(addressId).json"
        let headers = [
            "X-Shopify-Access-Token": NetworkConstants.token,
            "Content-Type": "application/json"
        ]
        
        let request = UpdateAddressRequest(address: address)
        
        NetworkManager.requestPUT(endpoint: endpoint, body: request, headers: headers) { (result: Result<CreateAddressResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.customer_address))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Delete Address
    func deleteAddress(customerId: Int, addressId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "\(NetworkConstants.baseURL)/customers/\(customerId)/addresses/\(addressId).json"
        let headers = [
            "X-Shopify-Access-Token": NetworkConstants.token
        ]
        
        NetworkManager.requestDELETE(endpoint: endpoint, headers: headers) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Set Default Address
    func setDefaultAddress(customerId: Int, addressId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "\(NetworkConstants.baseURL)/customers/\(customerId)/addresses/\(addressId)/default.json"
        let headers = [
            "X-Shopify-Access-Token": NetworkConstants.token
        ]
        
        NetworkManager.requestPUT(endpoint: endpoint, body: [:] as [String: String], headers: headers) { (result: Result<[String: String], Error>) in
            switch result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Default Address
    func getDefaultAddress(customerId: Int, completion: @escaping (Result<ShopifyAddress?, Error>) -> Void) {
        getCustomerAddresses(customerId: customerId) { result in
            switch result {
            case .success(let addresses):
                let defaultAddress = addresses.first { $0.isDefault == true }
                completion(.success(defaultAddress))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
>>>>>>> 739e222dabb6c3fab562a35dc022f1790aea94f0
}
