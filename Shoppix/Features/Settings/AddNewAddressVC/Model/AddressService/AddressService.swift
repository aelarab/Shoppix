//
//  AddressService.swift
//  SHOPPIX
//
//  Created by Nafea Elkassas on 04/11/2025.
//

import CoreData
import UIKit
final class AddressService {
    static let shared = AddressService()
    private init() {}
    
    private var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Create
    func addAddress(country: String, city: String, address: String, phone: String, isDefault: Bool = false) {
        let entity = AddressEntity(context: context)
        entity.id = UUID().uuidString
        entity.country = country
        entity.city = city
        entity.address = address
        entity.phone = phone
        entity.isDefault = isDefault
        entity.createdAt = Date()
        
        saveContext()
    }
    
    // MARK: - Fetch
    func fetchAddresses() -> [AddressEntity] {
        let request: NSFetchRequest<AddressEntity> = AddressEntity.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - Delete
    func deleteAddress(_ address: AddressEntity) {
        context.delete(address)
        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
