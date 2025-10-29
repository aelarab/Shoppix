//
//  ApiProtocol.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 25/10/2025.
//

import Foundation
protocol ApiProtocol{
    
    static func get<T: Decodable>(endPoint: EndPoints, completionHandeler: @escaping ((T?), Error?) -> Void)
    
    static func post<T: Codable>(endPoint: EndPoints, params: [String: Any], completionHandeler: @escaping ((T?), Error?) -> Void)
    
    static  func update<T: Codable>(endPoint: EndPoints, params: [String: Any], completionHandeler: @escaping ((T?), Error?) -> Void)
    
    static  func delete(endPoint: EndPoints)
    
}
