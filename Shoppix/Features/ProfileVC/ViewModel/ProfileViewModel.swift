//
//  ProfileViewModel.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 05/11/2025.
//

import Foundation
class ProfileViewModel {
    func getUserFullName(completion: @escaping (String?) -> Void) {
           FireBaseService.shared.fetchCurrentUserName { fullName, error in
               if let error = error {
                   print("Error fetching user name: \(error.localizedDescription)")
                   completion(nil)
               } else {
                   completion(fullName)
               }
           }
       }
}
