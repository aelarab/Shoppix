//
//  NetworkManager.swift
//  SHOPPIX
//
//  Created by adham ragap on 29/10/2025.
//

import Foundation
import UIKit

enum NetworkHTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

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
       
       guard CheckInternet().Connection() else {
                  DispatchQueue.main.async {
                      if let topController = UIApplication.shared.keyWindow?.rootViewController {
                          let alert = UIAlertController(
                              title: "⚠️ No Internet Connection",
                              message: "Please check your connection and try again.",
                              preferredStyle: .alert
                          )
                          alert.addAction(UIAlertAction(title: "OK", style: .default))
                          topController.present(alert, animated: true)
                      }
                  }
                  return
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
    func createShopifyCustomer(firstName: String, lastName: String, email: String, completion: @escaping (Int?) -> Void) {
        let shopifyToken = ProcessInfo.processInfo.environment["SHOPIFY_ACCESS_TOKEN"] ?? ""
        guard let url = URL(string: "https://iosr1g1.myshopify.com/admin/api/2025-07/customers.json") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(shopifyToken, forHTTPHeaderField: "X-Shopify-Access-Token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ShopifyCustomerRequest(customer: CustomerData(first_name: firstName,
                                                                 last_name: lastName,
                                                                 email: email,
                                                                 verified_email: true))

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(ShopifyCustomerResponse.self, from: data)
                completion(decoded.customer.id)
            } catch {
                print("Decode error:", error)
                completion(nil)
            }
        }.resume()
    }
    
    
       //MARK: - New methods for shopify api integration
    static func requestGET<T: Codable>(
            endpoint: String,
            headers: [String: String]? = nil,
            completion: @escaping (Result<T, Error>) -> Void
        ) {
            getData(url: endpoint, headers: headers) { (data: T?, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let data = data {
                    completion(.success(data))
                }
            }
        }
        
        
        // MARK: - ✅ New: Universal POST Request
        static func requestPOST<T: Codable, U: Codable>(
            endpoint: String,
            body: T,
            headers: [String: String]? = nil,
            completion: @escaping (Result<U, Error>) -> Void
        ) {
            guard let url = URL(string: endpoint) else { return }
            var request = URLRequest(url: url)
            request.httpMethod = NetworkHTTPMethod.post.rawValue
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            headers?.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
            
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(error))
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "NoData", code: -1)))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(U.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
}
