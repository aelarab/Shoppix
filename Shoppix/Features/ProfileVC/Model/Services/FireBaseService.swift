//
//  FireBaseService.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 05/11/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FireBaseService {
    static let shared = FireBaseService()
    private init() {}

    func fetchCurrentUserName(completion: @escaping (String?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "FirebaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No logged-in user"]))
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = snapshot?.data(),
                  let firstName = data["firstName"] as? String,
                  let lastName = data["lastName"] as? String else {
                completion(nil, NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User data not found"]))
                return
            }

            let fullName = "\(firstName) \(lastName)"
            completion(fullName, nil)
        }
    }
}
