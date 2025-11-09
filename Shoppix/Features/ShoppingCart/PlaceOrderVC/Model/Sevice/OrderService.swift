//
//  OrderService.swift
//  Shoppix
//
//  Created by Nafea Elkassas on 09/11/2025.
//

import Foundation

import Foundation

final class OrderService {
    static let shared = OrderService()
    private init() {}

    private let baseURL = "\(NetworkConstants.baseURL)"
    private let token = NetworkConstants.token

    func createOrder(
        email: String,
        lineItems: [[String: Any]],
        shippingAddress: [String: Any],
        paymentMethod: String,
        totalAmount: String, // formatted string, 2 decimals
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/orders.json") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "X-Shopify-Access-Token")

        let body: [String: Any] = [
            "order": [
                "email": email,
                "send_receipt": true,
                "send_fulfillment_receipt": true,
                "line_items": lineItems,
                "shipping_address": shippingAddress,
                "transactions": [
                    [
                        "kind": "sale",
                        "status": "success",
                        "gateway": paymentMethod,
                        "amount": totalAmount
                    ]
                ]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📦 Status code:", httpResponse.statusCode)
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("🧾 Shopify Response JSON:\n\(jsonString)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let order = json["order"] as? [String: Any],
                   let orderId = order["id"] as? Int {

                    self.sendConfirmationEmail(orderId: orderId) { result in
                        switch result {
                        case .success:
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    completion(.failure(NSError(domain: "", code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to parse order ID from JSON."])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func sendConfirmationEmail(orderId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/orders/\(orderId)/send.json") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "X-Shopify-Access-Token")

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            print("📧 Shopify confirmation email triggered for order \(orderId)")
            completion(.success(()))
        }.resume()
    }
}
