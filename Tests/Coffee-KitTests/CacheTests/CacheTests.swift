//
//  CacheTests.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 16.05.25.
//

@testable import Coffee_Kit
import Foundation
import XCTest

final class CacheTests: XCTestCase {
    private let ids = ["e074867a-0c6a-49ff-87ca-b1ba5dae5236",
                       "07515180-3f06-46ab-99ce-64660db57cb8",
                       "3cfc8e2b-95b1-461c-a84b-21215dee5a7f",
                       "01dc289a-4bb0-407c-b5a6-a6a868ab0101",
                       "25e604dc-3308-484b-873d-0491d5ad4e9d",
                       "ea412375-bc6d-4843-94a0-0499f222595d",
                       "ad219501-95f9-43b6-b323-fd615f0ee68c",
                       "2581830d-b927-4be4-a2cf-774179f87b4d",
                       "5ac22c68-2ada-446e-b497-ca24a31d967e",
                       "d607034c-94be-4225-8275-d960e88020c9",
                       "c4adb030-0863-481d-ba7c-68b404607b84",
                       "f336aa07-fbba-4a79-9c7a-8c58031eef99"]

    // MARK: - Properties

    func testCaching() async throws {
        let productService = await ProductService(databaseAPI: .dev)
        let cache = Cache<String, Product>(memoryLimit: 200)
        let cappuccinoId = "01dc289a-4bb0-407c-b5a6-a6a868ab0101"

        guard let _ = try? await cache.fetch(key: cappuccinoId, with: productService.load)
        else {
            XCTFail("Failed to fetch product")
            return
        }

        let isCached = await cache.contains(key: cappuccinoId)
        print("Is product cached: \(isCached)")

        guard let cappuccino = await cache.get(key: cappuccinoId)
        else {
            XCTFail("Failed to fetch product from cache")
            return
        }
        XCTAssertNotNil(cappuccino, "Product should be cached")
    }

    func testCacheMemoryLimit() async throws {
        let productService = await ProductService(databaseAPI: .dev)
        let cache = Cache<String, Product>()

        for id in ids { // FIX memorie limit
            guard let _ = try? await cache.fetch(key: id, with: productService.load)
            else {
                XCTFail("Failed to fetch product")
                return
            }

            let isCached = await cache.contains(key: id)
            print("Product is cached: \(isCached)")

            let currentMemoryUsage = await cache.memoryUsage
            print("Current memory usage: \(currentMemoryUsage)")
        }
    }

    func testCacheInitilisationWithKeyList() async throws {
        let productService = await ProductService(databaseAPI: .dev)

        guard let productCache = try? await Cache.create(by: ids, with: productService.load)
        else {
            XCTFail("Failed to fetch product")
            return
        }

        let isCached = await productCache.contains(key: ids[0])
        XCTAssertTrue(isCached, "Product should be cached")

        let product = await productCache.get(key: ids[0])
        XCTAssertNotNil(product, "Product should be cached")

        let count = await productCache.count
        print("Cached products: \(count)")
        XCTAssertEqual(count, ids.count, "All products should be cached")
    }

    func testDataCaching() async throws {
        let imageService = await ImageService(databaseAPI: .dev)
        let imageCache = await imageService.imageCache
        let testProduct = Product()

        let data = try await imageService.getImageData(for: testProduct)
        XCTAssertNotNil(data, "Image data should not be nil")

        let cachedData = await imageCache.get(key: testProduct.imageName)
        XCTAssertNotNil(cachedData, "Cached image data should not be nil")
    }
}
