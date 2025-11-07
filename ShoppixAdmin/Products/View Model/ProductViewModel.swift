//
//  ProductViewModel.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 26/10/2025.
//

import Foundation
import Alamofire

class ProductViewModel{
    
    var bindResultToProduct: (() -> ()) = {}
    var bindProductCustomCollection: (() -> ()) = {}
    
    var newProduct : ProductInfoResponse!{
        didSet{
            bindResultToProduct()
        }
    }

    var productCustomCollection : ProductCustomCollectionModel!{
        didSet{
            bindProductCustomCollection()
        }
    }
    
    func createProduct(product:Product){
        let params : Parameters = Utils.encodeToJson(objectClass:ProductInfoResponse(product: product))!
        Api.post(endPoint: EndPoints.createProduct, params: params) { [weak self] (data: ProductInfoResponse?, error) in
            guard let responsData = data else{ return}
            self?.newProduct = responsData
        }
    }
    
    func createProductImg(params: [String: Any], id: Int){
        Api.post(endPoint: EndPoints.createProductImg(id: id), params: params) { (data: ProductImgModel?, error) in
            
        }
    }
    
    func addProdoctCustomCollection(params: [String: Any]){
        Api.post(endPoint: EndPoints.addProductToCustomCollection, params: params) {(data: ProductCustomCollectionModel?, error) in
            guard let responsData = data else{ return}
            self.productCustomCollection = responsData
            print(self.productCustomCollection.collect.collection_id)
            
        }
    }
    

    
    func editProduct(product:Product){
        let params : Parameters = Utils.encodeToJson(objectClass:ProductInfoResponse(product: product))!
        
        Api.update(endPoint: EndPoints.updateProduct(id: product.id!), params: params) { [weak self] (data: ProductInfoResponse?, error) in
            guard let responsData = data else{ return}
            self?.newProduct = responsData
        }
    }
    
    
    func updateVariants(product: Product){
        for variant in product.variants!{
            if variant.id != nil {
                let inventoryLevel = InventoryLevel(inventoryItemId: variant.inventoryItemId, locationId: Int(Constants.location), available: variant.inventoryQuantity
                )
                let params : Parameters = Utils.encodeToJson(objectClass:InventoryLevelResponse(inventoryLevel:inventoryLevel))!
                
                Api.post(endPoint: EndPoints.inventorySet, params: params) {  (data: InventoryLevelResponse?, error) in
                    guard let responsData = data else{ return}
                    
                    print(responsData.inventoryLevel?.locationId ?? 1)
                }
                
            }
        }
    }
}
