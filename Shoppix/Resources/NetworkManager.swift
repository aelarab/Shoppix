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
            } else {
                // Debug: Print what we actually received
                if let url = URL(string: endpoint) {
                    URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
                        if let data = data, let rawString = String(data: data, encoding: .utf8) {
                            print("🔍 DEBUG - Raw response for \(endpoint):")
                            print(rawString)
                        }
                    }.resume()
                }
                completion(.failure(NSError(domain: "No data received", code: -1)))
            }
        }
    }
        
        // MARK: - ✅ New: Universal POST Request
    static func requestPOST<T: Codable>(
        endpoint: String,
        body: Codable,
        headers: [String: String],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -2)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                // 🧩 Log raw response to debug
                if let raw = String(data: data, encoding: .utf8) {
                    print("⚠️ Raw Shopify Response:\n\(raw)")
                }
                completion(.failure(error))
            }
        }.resume()
    }
    
    // Add to NetworkManager
    static func requestPUT<T: Codable>(
        endpoint: String,
        body: Codable,
        headers: [String: String],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -2)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                if let raw = String(data: data, encoding: .utf8) {
                    print("⚠️ Raw Shopify PUT Response:\n\(raw)")
                }
                completion(.failure(error))
            }
        }.resume()
    }

    
}
// Add this extension to NetworkManager
extension NetworkManager {
    
    // Generic method to get JSON as Dictionary
    static func getGenericData(
        url: String,
        headers: [String: String]? = nil,
        completion: @escaping ([String: Any]?, Error?) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: -2))
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(jsonObject, nil)
                } else if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
                    // Handle array response
                    completion(["data": jsonArray], nil)
                } else {
                    completion(nil, NSError(domain: "Invalid JSON", code: -3))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    // Debug method
    static func debugAPIResponse(url: String, headers: [String: String]? = nil) {
        guard let url = URL(string: url) else {
            print("❌ Invalid URL: \(url)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        print("🔍 Debug API Call to: \(url)")
        print("📋 Headers: \(headers ?? [:])")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Status Code: \(httpResponse.statusCode)")
                print("📋 Response Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let data = data {
                if let rawString = String(data: data, encoding: .utf8) {
                    print("📦 Raw Response Data:")
                    print(rawString.prefix(1000)) // Limit output
                } else {
                    print("❌ Cannot convert data to string")
                }
            } else {
                print("❌ No data received")
            }
        }.resume()
    }
    
    // MARK: - DELETE Request
    static func requestDELETE(
        endpoint: String,
        headers: [String: String],
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        headers.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(true))
                } else {
                    completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode)))
                }
            } else {
                completion(.failure(NSError(domain: "No Response", code: -2)))
            }
        }.resume()
    }
}
