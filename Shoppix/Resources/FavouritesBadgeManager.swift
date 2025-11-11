//
//  FavouritesBadgeManager.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 11/11/2025.
//

import UIKit
import CoreData

final class FavoritesBadgeManager {
    static let shared = FavoritesBadgeManager()
    private init() {}
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func updateFavoritesBadge(for button: UIBarButtonItem) {
        guard let userId = UserDefaults.standard.string(forKey: "userId") else {
            button.showDotBadge(shouldShow: false)
            return
        }
        
        let request: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        
        do {
            let favorites = try context.fetch(request)
            button.showDotBadge(shouldShow: !favorites.isEmpty)
        } catch {
            print(" Failed to fetch favorites: \(error.localizedDescription)")
            button.showDotBadge(shouldShow: false)
        }
    }
}
