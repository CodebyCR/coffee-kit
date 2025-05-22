//
//  Untitled.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 18.05.25.
//


public protocol FetchAction<T, R>: Sendable {
    @Sendable public consuming func callAsFunction(_ param: T) async throws -> R
}


public struct MenuFetchAction<UUID, Product>: FetchAction {
    public typealias T = UUID
    public typealias R = Product
    
    let fetch: (UUID) async throws -> Product
    
    @Sendable public consuming func callAsFunction(_ param: UUID) async throws -> Product {
        try await fetch(param)
    }
}












