//
//  Untitled.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 13.03.25.
//

import Foundation

public final class OrderProduct {
    public let product: Product
    @Published public var quantity: UInt8

    // MARK: - Initializer

    public init() {
        self.product = Product()
        self.quantity = 1
    }

    public init(product: Product, quantity: UInt8 = 1) {
        self.product = product
        self.quantity = quantity
    }
}

// MARK: - Computed Properties

public extension OrderProduct {
    var price: Double {
        guard quantity > 0 else { return 0.0 }

        return Double(quantity) * product.price
    }
}

// MARK: - Identifiable

extension OrderProduct: Identifiable {
    public var id: UUID {
        product.id
    }
}

// MARK: - Sendable

extension OrderProduct: Sendable {}

// MARK: - CustomDebugStringConvertible

extension OrderProduct: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        OrderProduct:
            product=\(product),
            quantity=\(quantity)
        """
    }
}

// MARK: - ObservableObject

extension OrderProduct: ObservableObject {}

// MARK: - Equatable

extension OrderProduct: Equatable {
    public static func == (lhs: OrderProduct, rhs: OrderProduct) -> Bool {
        lhs.product == rhs.product && lhs.quantity == rhs.quantity
    }
}

// MARK: - Hashable

extension OrderProduct: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(product.id)
        hasher.combine(quantity)
    }
}

