//
//  ProductsViewModel.swift
//  ShoppixAdmin
//
//  Created by Ahmed Mohamed on 26/10/2025.
//

import Foundation
class ProductsViewModel {
    
    var bindResultToDisplayProducts: (( ) -> Void)?
    
    var allProducts : ProductsResponse!{
        didSet{
            bindResultToDisplayProducts?()
            
        }
    }
    
    func getAllProducts (){
        Api.get(endPoint: EndPoints.createProduct ) { [weak self] (data : ProductsResponse? , error ) in
            guard let data = data else{ return}
            self?.allProducts = data
     
        }
    }
    
    func deleteProduct(productId: Int){
        Api.delete(endPoint: EndPoints.updateProduct(id: productId))
    }
}
