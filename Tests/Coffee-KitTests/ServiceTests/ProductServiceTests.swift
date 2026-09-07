//
//  ProductServiceTests.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 15.05.25.
//

import Foundation
import Testing
import FoundationKit
import AuthenticationKit
import ProductKit
import OrderKit
import ImageKit

@Suite("Product Service Tests")
@MainActor
struct ProductServiceTests {

#if DEBUG
    @Test("Load all product IDs", .requiresAPI)
    func loadAllIds() async throws {
        let keychain = DefaultKeychainManager()
        let databaseAPI: DatabaseAPI = .dev
        let authenticationManager = AutenticationManager(keychain: keychain, databaseAPI: databaseAPI)
        let webserviceProvider = WebserviceProvider(inMode: databaseAPI, autheticationManager: authenticationManager)
        let productService = ProductService(webserviceProvider: webserviceProvider)
        
        guard let ids = try? await productService.getIds() else {
            Issue.record("Failed to fetch product IDs")
            return
        }

        print("Fetched product IDs: \(ids)")
        #expect(!ids.isEmpty, "Product IDs should not be empty")
    }

    @Test("Fetch product by ID", .requiresAPI)
    func fetchProductById() async throws {
        let keychain = DefaultKeychainManager()
        let databaseAPI: DatabaseAPI = .dev
        let authenticationManager = AutenticationManager(keychain: keychain, databaseAPI: databaseAPI)
        let webserviceProvider = WebserviceProvider(inMode: databaseAPI, autheticationManager: authenticationManager)
        let productService = ProductService(webserviceProvider: webserviceProvider)
        
        let cappuccinoId = "01dc289a-4bb0-407c-b5a6-a6a868ab0101"

        guard let product = try? await productService.load(by: cappuccinoId) else {
            Issue.record("Failed to fetch product")
            return
        }

        print("Fetched product: \(product)")

        #expect(product.name == "Cappuccino", "Product name should match")
    }

    @Test("Fetch all products", .requiresAPI)
    func fetchAllProducts() async throws {
        let keychain = DefaultKeychainManager()
        let databaseAPI: DatabaseAPI = .dev
        let authenticationManager = AutenticationManager(keychain: keychain, databaseAPI: databaseAPI)
        let webserviceProvider = WebserviceProvider(inMode: databaseAPI, autheticationManager: authenticationManager)
        let productService = ProductService(webserviceProvider: webserviceProvider)
        
        guard let products = try? await productService
            .loadAll()
            .collect(into: [Result<Product, Error>]())
        else {
            Issue.record("Failed to fetch products")
            return
        }

        let successProducts: [Product] = products.compactMap { try? $0.get() }
        print("Fetched product count: \(successProducts.count)")

        #expect(!successProducts.isEmpty, "Products should not be empty")
    }
#endif
}
