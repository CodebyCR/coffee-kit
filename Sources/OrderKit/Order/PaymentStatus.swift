//
//  PaymentStatus.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 22.04.26.
//

import Foundation

nonisolated public enum PaymentStatus: String, CaseIterable, Identifiable {
    case pending = "pending"
    case paid = "paid"
    case failed = "failed"
    case unknown = "unknown"

    public var id: Self { self }

    public static func get(by name: String) -> Self {
        let name = name.lowercased()
        return allCases.first { $0.rawValue == name } ?? .unknown
    }
}
