//
//  ShoppixTests.swift
//  ShoppixTests
//
//  Created by adham ragap on 03/11/2025.
//

import XCTest
@testable import Shoppix

class ShoppixTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testLoadVendors(){
        let expectaion = expectation(description: "waiting for Vendor remote data")
        NetworkManager.getData(url: "https://iosr1g1.myshopify.com/admin/api/2025-07/smart_collections.json", headers: [
            "X-Shopify-Access-Token":"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",
            "Content-Type":"application/json"
           
        ]) { [weak self]  (smartCollectionModel:SmartCollectionModel?, error) in
            expectaion.fulfill()
            if error == nil {
                guard let smartCollection = smartCollectionModel else {
                    XCTFail("❌ smartCollectionModel is nil")
                    return
                }
                XCTAssert(smartCollection.smart_collections.count >  0)
            } else {
                XCTFail()
            }
        }
      
        waitForExpectations(timeout: 15)
    }
    
    func testLoadproducts(){
        let expectaion = expectation(description: "waiting for products remote data")
        let vendor = "ADIDAS"
        NetworkManager.getData(url: "https://iosr1g1.myshopify.com/admin/api/2025-07/smart_collections.json?vendor=\(vendor)", headers: [
            "X-Shopify-Access-Token":"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",
            "Content-Type":"application/json"
           
        ]) { [weak self]  (productModel:ProductModel?, error) in
            expectaion.fulfill()
            if error == nil {
                guard let productModel = productModel else {
                    XCTFail("❌ productModel is nil")
                    return
                }
                XCTAssert(productModel.products.count >  0)
            } else {
                XCTFail()
            }
        }
      
        waitForExpectations(timeout: 15)
    }
    func testLoadproductDetails(){
        let expectaion = expectation(description: "waiting for product details remote data")
        let productId = 7936265158719
        NetworkManager.getData(url: "https://iosr1g1.myshopify.com/admin/api/2025-07/products/\(productId).json", headers: [
            "X-Shopify-Access-Token":"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",
            "Content-Type":"application/json"
           
        ]) { [weak self]  (detailsRespone:SingleProductModel?, error) in
            expectaion.fulfill()
            if error == nil {
                guard let detailsRespone = detailsRespone else {
                    XCTFail("❌ detailsRespone is nil")
                    return
                }
                XCTAssertNotNil(detailsRespone.product, "❌ Product is nil")
            } else {
                XCTFail()
            }
        }
      
        waitForExpectations(timeout: 15)
    }
    
    func testRequestPOST_CreateProduct() {
        let expectation = expectation(description: "Waiting for POST request to complete")
        
        struct ProductBody: Codable {
            let product: ProductData
        }

        struct ProductData: Codable {
            let title: String
            let body_html: String
            let vendor: String
            let product_type: String
        }

        let body = ProductBody(product: ProductData(
            title: "Test Product \(UUID().uuidString)",
            body_html: "Created from unit test",
            vendor: "UnitTestVendor",
            product_type: "TestType"
        ))


        let headers = [
            "X-Shopify-Access-Token": "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",
            "Content-Type": "application/json"
        ]

        let endpoint = "https://iosr1g1.myshopify.com/admin/api/2025-07/products.json"

        NetworkManager.requestPOST(
            endpoint: endpoint,
            body: body,
            headers: headers
        ) { (result: Result<SingleProductModel, Error>) in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response.product, " Product is nil in response")
                print(" Created product with ID: \(response.product.id ?? 0)")
            case .failure(let error):
                XCTFail(" Request failed with error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 15)
    }
    
    func testUpdateProductDetails() {
        let expectation = expectation(description: "Waiting for PUT request to complete")
        
        let productId = 7936265158719
        let endpoint = "https://iosr1g1.myshopify.com/admin/api/2025-07/products/\(productId).json"
        
        let headers = [
            "X-Shopify-Access-Token": "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",
            "Content-Type": "application/json"
        ]
        
        struct UpdateProductBody: Codable {
            let product: ProductUpdate
        }
        
        struct ProductUpdate: Codable {
            let id: Int
            let title: String
        }
        
        let body = UpdateProductBody(
            product: ProductUpdate(id: productId, title: "Updated Product Title")
        )
        
        NetworkManager.requestPUT(
            endpoint: endpoint,
            body: body,
            headers: headers
        ) { (result: Result<SingleProductModel, Error>) in
            switch result {
            case .success(let response):
                XCTAssertNotNil(response.product, " Product is nil in response")
                XCTAssertEqual(response.product.title, "Updated Product Title", " Title did not update correctly")
                print("PUT request succeeded and updated product title")
            case .failure(let error):
                XCTFail("PUT request failed: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15)
    }
}
