//
//  CoffeeService.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 22.01.25.
//

import Foundation

@MainActor
public struct ProductService {
    // MARK: Properties

    let productURL: URL
    private(set) var menuCache = Cache<String, Product>()

    // MARK: Initializer

    public init(databaseAPI: DatabaseAPI) {
        self.productURL = databaseAPI.baseURL / "coffee"
        print(productURL)
    }

    // MARK: Methods

    @Sendable public consuming func getIds() async throws -> [String] {
        let productIdsUrl = productURL / "ids"
        let (data, response) = try await URLSession.shared.data(from: productIdsUrl)

        guard let productIds = try? JSONDecoder().decode([String].self, from: data) else {
            print(response)
            print("""
            Error in \(#file)
            \t\(#function) \(#line):\(#column)
            \tStatus code: \((response as? HTTPURLResponse)?.statusCode ?? 0)
            """)
            throw FetchError.decodingError
        }

        return productIds
    }

    @Sendable public consuming func load(by id: String) async throws -> Product {
        let coffeeByIdUrl = productURL / "id" / id

        if let cachedProduct = await menuCache[id] {
            return cachedProduct
        }

        let (data, response) = try await URLSession.shared.data(from: coffeeByIdUrl)

        guard let product = try? JSONDecoder().decode(Product.self, from: data) else {
            print(response)

            let stacktrace = Thread.callStackSymbols.joined(separator: "\n")
            print(stacktrace)
            print("""
            Error in \(#file)
            \t\(#function) \(#line):\(#column)
            \tStatus code: \((response as? HTTPURLResponse)?.statusCode ?? 0)
            """)
            throw FetchError.decodingError
        }

        await menuCache.set(key: id, value: product)

        return product
    }

    @Sendable public consuming func load(with id: consuming String) async -> Product? {
        guard let product = try? await load(by: id)
        else {
            print(FetchError.decodingError)
            return nil
        }
        return product
    }

    @Sendable public func load(by ids: [String]) async -> AsyncThrowingStream<Product, Error> {
        return AsyncThrowingStream<Product, Error> { continuation in
            Task {
                do {
                    for id in ids {
                        let productModel = try await load(by: id)
                        continuation.yield(productModel)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    @Sendable public func loadAll() async -> AsyncStream<Result<Product, Error>> {
        return AsyncStream<Result<Product, Error>> { continuation in
            Task {
                do {
                    let ids = try await getIds()
                    for id in ids {
                        let product = try await load(by: id)
                        continuation.yield(.success(product))
                    }
                } catch {
                    continuation.yield(.failure(error))
                }
                continuation.finish()
            }
        }
    }

    public func loadCuncurrently(by ids: [String]) async -> AsyncThrowingStream<Product, Error> {
        return ids.concurrentMap { id in
            try await load(by: id)
        }
    }

    @Sendable public func fillUpCache() async throws {
        guard let ids = try? await getIds()
        else {
            print("Failed to fetch product IDs")
            throw FetchError.invalidResponse
        }

        do {
            try await menuCache.fillUp(by: ids, with: load)
        } catch {
            print("Error filling up cache: \(error)")
            throw FetchError.invalidResponse
        }
    }
}
