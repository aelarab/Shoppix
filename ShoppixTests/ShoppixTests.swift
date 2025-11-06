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
}
