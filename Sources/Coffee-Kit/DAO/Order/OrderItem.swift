//
//  ProductQuantity.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 06.03.25.
//

import Foundation

nonisolated public struct OrderItem {
    public let id: UUID
    public var quantity: UInt8
}

// MARK: - Codable

nonisolated extension OrderItem: Codable {
    enum CodingKeys: String, CodingKey {
        case quantity
        case id
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quantity = try container.decode(UInt8.self, forKey: .quantity)
        id = try container.decode(UUID.self, forKey: .id)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(id, forKey: .id)
    }
}

// MARK: - Identifiable

nonisolated extension OrderItem: Identifiable {}

// MARK: - Sendable

nonisolated extension OrderItem: Sendable {}

// MARK: - CustomDebugStringConvertible

nonisolated extension OrderItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        OrderItem:
            id=\(id),
            quantity=\(quantity)
        """
    }
}

nonisolated extension OrderItem: Equatable {
    
    public static func == (lhs: OrderItem, rhs: OrderItem) -> Bool {
        lhs.id == rhs.id
    }
    
}

nonisolated extension OrderItem: Hashable {}

// MARK: - Methods
