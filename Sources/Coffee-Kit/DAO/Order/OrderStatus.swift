//
//  OrderStatus.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 22.04.26.
//

import Foundation

nonisolated public enum OrderStatus: String, CaseIterable, Identifiable {
    case ordered = "ordered"
    case inPreparation = "in preparation"
    case inDelivery = "in delivery"
    case delivered = "delivered"
    case cancelled = "cancelled"
    case unknown = "unknown"

    public var id: Self { self }

    public static func get(by name: String) -> Self {
        let name = name.lowercased()
        return allCases.first { $0.rawValue == name } ?? .unknown
    }

}
