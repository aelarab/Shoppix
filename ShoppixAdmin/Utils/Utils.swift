
import Foundation
import UIKit

class Utils{
    
    static func encodeToJson<T: Codable>(objectClass: T) -> [String: Any]?{
        do{
            let jsonData = try JSONEncoder().encode(objectClass)
            let json = String(data: jsonData, encoding: String.Encoding.utf8)!
            return jsonToDictionary(from: json)
        }catch let error{
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func jsonToDictionary(from text: String) -> [String: Any]? {
        guard let data = text.data(using: .utf8) else { return nil }
        let anyResult = try? JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String : Any]
    }
}
