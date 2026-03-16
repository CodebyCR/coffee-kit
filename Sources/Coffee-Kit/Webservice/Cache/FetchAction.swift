//
//  Untitled.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 18.05.25.
//

import Foundation


public protocol ExpressibleByFunctionLiteral: Sendable, ~Copyable {
    associatedtype T
    associatedtype R

    @Sendable func callAsFunction(_ param: T) async throws -> R
}

public protocol FetchAction<Param, RetrurnType>: Sendable, ~Copyable, ExpressibleByFunctionLiteral {
    associatedtype Param
    associatedtype RetrurnType

    @Sendable consuming func callAsFunction(_ param: Param) async throws -> RetrurnType
}


public struct MenuFetchAction<UUID, Product>: FetchAction{
    public typealias T = UUID
    public typealias R = Product

    let fetch:  @Sendable (UUID) async throws -> Product

    @Sendable public func callAsFunction(_ param: UUID) async throws -> Product {
        try await fetch(param)
    }
}

// main like test

let fetchAction = MenuFetchAction<UUID, Product> { _ in
    // Simulate fetching a product by UUID
    return Product()
}

struct SomeStruct {

    @Sendable func fetch(by uuid: UUID) async throws -> Product {
        // Simulate fetching a product by UUID
        return Product()
    }
}

//let fetchAction2 = MenuFetchAction<UUID, Product>.init(fetch: SomeStruct.fetch)




func testFetchAction(_ fetchAction: MenuFetchAction<UUID, Product>) async throws {
    let uuid = UUID()
    let product = try await fetchAction(uuid)
    print("Fetched product: \(product)")
}


func test() async {
    try? await testFetchAction(fetchAction)
}













