//
//  CollectionsViewModel.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 26/10/2025.
//
import Foundation

class CollectionsViewModel {
    
    var bindResultToDisplayBrands: (( ) -> Void)?
    
    var bindCustomCollection: (() -> ()) = {}
    
    var allBrands : AllSmartCollectionModel!{
        didSet{
            bindResultToDisplayBrands?()
            
        }
    }
    
    var allCustomCollection : AllCustomCollectionModel!{
        didSet{
            bindCustomCollection()
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
    
}
