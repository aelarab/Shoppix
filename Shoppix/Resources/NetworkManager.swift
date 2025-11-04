//
//  NetworkManager.swift
//  SHOPPIX
//
//  Created by adham ragap on 29/10/2025.
//

import Foundation
protocol NetworkManagerDelegete {
    static func getData<T:Codable>(url: String, headers: [String: String]?,complationHandler: @escaping (T?,Error?)->Void)
}
class NetworkManager:NetworkManagerDelegete{
   static func getData<T:Codable>(url: String, headers: [String: String]? = nil, complationHandler: @escaping (T?, Error?) -> Void) {
       guard let url = URL(string: url) else { return }
       var request = URLRequest(url: url)
              request.httpMethod = "GET"
       if let headers = headers {
                   for (key, value) in headers {
                       request.addValue(value, forHTTPHeaderField: key)
                   }
               }
       
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                                print("❌ Network error: \(error.localizedDescription)")
                    complationHandler(nil, error)
                                return
                            }
                guard let data = data, !data.isEmpty else {
                               print("⚠️ No data received from server")
                    complationHandler(nil, nil)
                               return
                           }
                do{
                        let fetchedData = try
                        JSONDecoder().decode(T.self, from: data)
                        complationHandler(fetchedData,nil)
                    }catch(let error as NSError){
                      print("cannot decoding because : \(error)")
                        complationHandler(nil,error)
                    }
                    
                
               
            }.resume()
        
    }
    
    
}
