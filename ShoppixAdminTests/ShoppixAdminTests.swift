//
//  ShoppixAdminTests.swift
//  ShoppixAdminTests
//
//  Created by Ahmed Mohamed on 23/10/2025.
//

import XCTest
@testable import ShoppixAdmin

final class ShoppixAdminTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testGetSuccess() {
        let mockApi = MockApiClient()
        let expected = "TestData"
        mockApi.getResult = expected
        let endpoint = DummyEndPoint()
        let expectation = self.expectation(description: "get completion")
        mockApi.get(endPoint: endpoint) { (result: String?, error) in
            XCTAssertEqual(result, expected)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    func testPostSuccess() {
        let mockApi = MockApiClient()
        let expected = 123
        mockApi.postResult = expected
        let endpoint = DummyEndPoint()
        let expectation = self.expectation(description: "post completion")
        mockApi.post(endPoint: endpoint, params: [:]) { (result: Int?, error) in
            XCTAssertEqual(result, expected)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    func testUpdateSuccess() {
        let mockApi = MockApiClient()
        let expected = true
        mockApi.updateResult = expected
        let endpoint = DummyEndPoint()
        let expectation = self.expectation(description: "update completion")
        mockApi.update(endPoint: endpoint, params: [:]) { (result: Bool?, error) in
            XCTAssertEqual(result, expected)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    func testDeleteSuccess() {
        let mockApi = MockApiClient()
        mockApi.deleteResult = true
        let endpoint = DummyEndPoint()
        let expectation = self.expectation(description: "delete completion")
        mockApi.delete(endPoint: endpoint) { (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    func testGetFailure() {
        let mockApi = MockApiClient()
        mockApi.error = NSError(domain: "Test", code: 1)
        let endpoint = DummyEndPoint()
        let expectation = self.expectation(description: "get error")
        mockApi.get(endPoint: endpoint) { (result: String?, error) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    func testPostFailure() {
        let mockApi = MockApiClient()
        mockApi.error = NSError(domain: "Test", code: 1)
        let endpoint = DummyEndPoint()
        let expectation = self.expectation(description: "post error")
        mockApi.post(endPoint: endpoint, params: [:]) { (result: Int?, error) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    func testUpdateFailure() {
        let mockApi = MockApiClient()
        mockApi.error = NSError(domain: "Test", code: 1)
        let endpoint = DummyEndPoint()
        let expectation = self.expectation(description: "update error")
        mockApi.update(endPoint: endpoint, params: [:]) { (result: Bool?, error) in
            XCTAssertNil(result)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    func testDeleteFailure() {
        let mockApi = MockApiClient()
        mockApi.error = NSError(domain: "Test", code: 1)
        mockApi.deleteResult = false // Ensure failure scenario
        let endpoint = DummyEndPoint()
        let expectation = self.expectation(description: "delete error")
        mockApi.delete(endPoint: endpoint) { (success, error) in
            XCTAssertFalse(success)
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    struct DummyEndPoint: EndPoints {
        var path: String { return "/dummy" }
    }
}


// MARK: - Protocol for API Client
protocol ApiProtocol {
    func get<T: Decodable>(endPoint: EndPoints, completionHandeler: @escaping ((T?, Error?) -> Void))
    func post<T: Codable>(endPoint: EndPoints, params: [String: Any], completionHandeler: @escaping ((T?, Error?) -> Void))
    func update<T: Codable>(endPoint: EndPoints, params: [String: Any], completionHandeler: @escaping ((T?, Error?) -> Void))
    func delete(endPoint: EndPoints, completionHandeler: @escaping ((Bool, Error?) -> Void))
}

// MARK: - Mock API Client
class MockApiClient: ApiProtocol {
    var getResult: Any?
    var postResult: Any?
    var updateResult: Any?
    var deleteResult: Bool = true
    var error: Error?

    func get<T>(endPoint: EndPoints, completionHandeler: @escaping ((T?, Error?) -> Void)) where T : Decodable {
        completionHandeler(getResult as? T, error)
    }
    func post<T>(endPoint: EndPoints, params: [String : Any], completionHandeler: @escaping ((T?, Error?) -> Void)) where T : Decodable, T : Encodable {
        completionHandeler(postResult as? T, error)
    }
    func update<T>(endPoint: EndPoints, params: [String : Any], completionHandeler: @escaping ((T?, Error?) -> Void)) where T : Decodable, T : Encodable {
        completionHandeler(updateResult as? T, error)
    }
    func delete(endPoint: EndPoints, completionHandeler: @escaping ((Bool, Error?) -> Void)) {
        completionHandeler(deleteResult, error)
    }
}

// MARK: - Protocol for EndPoints
protocol EndPoints {
    var path: String { get }
}
