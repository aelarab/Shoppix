//
//  CollectionsViewModel.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 26/10/2025.
//
import Foundation

class CollectionsViewModel {
    
    var bindResultToDisplayBrands: (() -> ()) = {}
    
    var bindCustomCollection: (() -> ()) = {}
    
    var bindProductsNum : (() -> ()) = {}
    
    var allBrands : AllSmartCollectionModel!{
        didSet{
            bindResultToDisplayBrands()
            
        }
    }
   
    var allCustomCollection : AllCustomCollectionModel!{
        didSet{
            bindCustomCollection()
        }
    }
    var numberOfProductsInCollection: CollectsResponse!{
        didSet{
            bindProductsNum()
            
        }
    }
    var numberOfProductsInBrands: ProductsResponse!{
        didSet{
            bindProductsNum()
        }
    }

    
    func getAllBrands(){
        Api.get(endPoint: EndPoints.createSmartCollection) { [weak self] (data : AllSmartCollectionModel? , error ) in
            guard let data = data else{ return}
            self?.allBrands = data
            print("data")
            print(data.smart_collections.count)
        }
    }
    
    func getAllCustomCollection(){
        Api.get(endPoint: EndPoints.createCustomCollection) { [weak self] (data : AllCustomCollectionModel? , error ) in
            guard let data = data else{ return}
            self?.allCustomCollection = data
        }
    }
    
    func deleteFromSmartCollection(smartCollectionId: Int){
        Api.delete(endPoint: EndPoints.editSmartCollection(id: smartCollectionId))
    }
    
    func deleteFromCustomCollection(customCollectionId: Int){
        Api.delete(endPoint: EndPoints.editCustomCollection(id: customCollectionId))
    }
    
    func updateSmartCollection(smartCollectionId: Int, title: String, imgUrl: String?, sortOrder: String?, completion: (() -> Void)? = nil) {
        var params: [String: Any] = [
            "smart_collection": [
                "title": title,
                "sort_order": sortOrder ?? "manual"
            ]
        ]
        if let imgUrl = imgUrl, !imgUrl.isEmpty {
            params["smart_collection"] = [
                "title": title,
                "sort_order": sortOrder ?? "manual",
                "image": ["src": imgUrl]
            ]
        }
        Api.update(endPoint: EndPoints.editSmartCollection(id: smartCollectionId), params: params) { [weak self] (response: AllSmartCollectionModel?, error: Error?) in
            self?.getAllBrands()
            completion?()
        }
    }

    func updateCustomCollection(customCollectionId: Int, title: String, completion: (() -> Void)? = nil) {
        let params: [String: Any] = [
            "custom_collection": [
                "title": title
            ]
        ]
        Api.update(endPoint: EndPoints.editCustomCollection(id: customCollectionId), params: params) { [weak self] (response: AllCustomCollectionModel?, error: Error?) in
            self?.getAllCustomCollection()
            completion?()
        }
    }
    
    func addSmartCollection(title: String, imgUrl: String, sortOrder: String, completion: (() -> Void)? = nil) {
        let params: [String: Any] = [
            "smart_collection": [
                "title": title,
                "sort_order": sortOrder,
                "rules": [
                    [
                        "column": "title",
                        "relation": "contains",
                        "condition": title
                    ]
                ],
                "image": ["src": imgUrl]
            ]
        ]
        Api.post(endPoint: EndPoints.createSmartCollection, params: params) { [weak self] (response: AllSmartCollectionModel?, error: Error?) in
            self?.getAllBrands()
            completion?()
        }
    }

    func addCustomCollection(title: String, completion: (() -> Void)? = nil) {
        let params: [String: Any] = [
            "custom_collection": [
                "title": title
            ]
        ]
        Api.post(endPoint: EndPoints.createCustomCollection, params: params) { [weak self] (response: AllCustomCollectionModel?, error: Error?) in
            self?.getAllCustomCollection()
            completion?()
        }
    }
}
extension CollectionsViewModel {
    
    func fetchProductsCount(collectionId: Int, completion: @escaping (Int) -> Void) {
        
        Api.get(endPoint: EndPoints.numberOfProductsInCollection(id: collectionId)) { (data: CollectsResponse?, error) in
            guard let data = data else {
                completion(0)
                return
            }
            completion(data.collects.count)
        }
    }
    func fetchProductsCountBrands(collectionId: Int, completion: @escaping (Int) -> Void) {
        
        Api.get(endPoint: EndPoints.numberOfProductsInSmartCollection(id: collectionId)) { (data: ProductsResponse?, error) in
            guard let data = data else {
                completion(0)
                return
            }
            completion(data.products?.count ?? 0)
        }
    }
}
