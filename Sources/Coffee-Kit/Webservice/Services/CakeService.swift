//
//  CakeService.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 22.01.25.
//

import Foundation

@MainActor
public struct CakeService {
    // MARK: Properties

    let cakeURL: URL

    // MARK: Initializer

    public init(databaseAPI: borrowing DatabaseAPI) {
        self.cakeURL = databaseAPI.baseURL / "cake"
    }

    // MARK: Methods

    public func getIds() async throws -> [String] {
        let cakeIdsUrls = cakeURL / "ids"
        let (data, response) = try await URLSession.shared.data(from: cakeIdsUrls)

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
        let cakeByIdUrl = cakeURL / "id" / id

        let (data, response) = try await URLSession.shared.data(from: cakeByIdUrl)

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
                        let cakeModel = try await load(by: id)
                        continuation.yield(cakeModel)
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
                        let cakeModel = try await load(by: id)
                        continuation.yield(.success(cakeModel))
                    }
                } catch {
                    continuation.yield(.failure(error))
                }
                continuation.finish()
            }
        }
    }
}
