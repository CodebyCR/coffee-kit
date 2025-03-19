//
//  Untitled.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 13.03.25.
//

import Foundation

public struct OrderProduct {
    public let product: Product
    public var quantity: UInt8
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
