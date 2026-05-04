//
//  File.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 15.05.25.
//

import Foundation
import XCTest
import FoundationKit
import AuthenticationKit
import ProductKit
import OrderKit
import ImageKit

@MainActor
final class ProductServiceTests: XCTestCase {

    // MARK: - Properties

#if DEBUG





    func testLoadAllIds() async throws {
        try skipUnlessAPITestsEnabled()
        let keychain = DefaultKeychainManager()
        let databaseAPI: DatabaseAPI = .dev
        let authenticationManager = AutenticationManager(keychain: keychain, databaseAPI: databaseAPI)
        let webserviceProvider = WebserviceProvider(inMode: databaseAPI, autheticationManager: authenticationManager)
        let productService = ProductService(webserviceProvider: webserviceProvider)
        
        
        guard let ids = try? await productService
            .getIds()

        else {
            XCTFail("Failed to fetch product IDs")
            return
        }

        print("Fetched product IDs: \(ids)")
        XCTAssertFalse(ids.isEmpty, "Product IDs should not be empty")
    }

    func testFetchProductById() async throws {
        try skipUnlessAPITestsEnabled()
        let keychain = DefaultKeychainManager()
        let databaseAPI: DatabaseAPI = .dev
        let authenticationManager = AutenticationManager(keychain: keychain, databaseAPI: databaseAPI)
        let webserviceProvider = WebserviceProvider(inMode: databaseAPI, autheticationManager: authenticationManager)
        let productService = ProductService(webserviceProvider: webserviceProvider)
        
        let cappuccinoId = "01dc289a-4bb0-407c-b5a6-a6a868ab0101"

        guard let product = try? await productService
            .load(by: cappuccinoId)
        else {
            XCTFail("Failed to fetch product")
            return
        }

        print("Fetched product: \(product)")

        XCTAssertNotNil(product, "Product should not be nil")
        XCTAssertEqual(product.name, "Cappuccino", "Product ID should match")
    }

    func testFetchAllProducts() async throws {
        try skipUnlessAPITestsEnabled()
        let keychain = DefaultKeychainManager()
        let databaseAPI: DatabaseAPI = .dev
        let authenticationManager = AutenticationManager(keychain: keychain, databaseAPI: databaseAPI)
        let webserviceProvider = WebserviceProvider(inMode: databaseAPI, autheticationManager: authenticationManager)
        let productService = ProductService(webserviceProvider: webserviceProvider)
        
        guard let products = try? await productService
            .loadAll()
            .collect(into: [Result<Product, Error>]())
        else {
            XCTFail("Failed to fetch products")
            return
        }

        let successProducts: [Product] = products.compactMap { try? $0.get() }
        print("Fetched product count: \(successProducts.count)")
        print(successProducts)

        XCTAssertFalse(successProducts.isEmpty, "Products should not be empty")
    }

//    func testFetchAllProductsConccurent() async {
//        guard let ids = try? await productService
//            .getIds()
//        else {
//            XCTFail("Failed to fetch product IDs")
//            return
//        }
//
//        let products = ids.compactMap { productId in
//            await productService.load(by: productId)
//        }
//
//    }

#endif

}

