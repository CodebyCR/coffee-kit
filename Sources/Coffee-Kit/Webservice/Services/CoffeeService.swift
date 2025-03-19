//
//  CoffeeService.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 22.01.25.
//

import Foundation

@MainActor
public struct CoffeeService {
    // MARK: Properties

    let coffeeURL: URL

    // MARK: Initializer

    public init(databaseAPI: DatabaseAPI) {
        self.coffeeURL = databaseAPI.baseURL / "coffee"
        print(coffeeURL)
    }

    // MARK: Methods

    public func getIds() async throws -> [String] {
        let coffeeIdsUrl = coffeeURL / "ids"
        let (data, response) = try await URLSession.shared.data(from: coffeeIdsUrl)

        guard let drinkIds = try? JSONDecoder().decode([String].self, from: data) else {
            print(response)
            print("""
            Error in \(#file)
            \t\(#function) \(#line):\(#column)
            \tStatus code: \((response as? HTTPURLResponse)?.statusCode ?? 0)
            """)
            throw FetchError.decodingError
        }

        return drinkIds
    }

    public func load(by id: consuming String) async throws -> Product {
        let coffeeByIdUrl = coffeeURL / "id" / id

        let (data, response) = try await URLSession.shared.data(from: coffeeByIdUrl)

        guard let coffee = try? JSONDecoder().decode(Product.self, from: data) else {
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

        return coffee
    }

    public func load(by ids: [String]) async -> AsyncThrowingStream<Product, Error> {
        return AsyncThrowingStream<Product, Error> { continuation in
            Task {
                do {
                    for id in ids {
                        let coffeeModel = try await load(by: id)
                        continuation.yield(coffeeModel)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    public func loadAll() async -> AsyncStream<Result<Product, Error>> {
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
}
