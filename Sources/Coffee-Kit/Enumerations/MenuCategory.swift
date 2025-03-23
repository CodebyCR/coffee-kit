//
//  MenuCategory.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 10.03.25.
//

import Foundation

public enum MenuCategory: String, CaseIterable, Hashable, Codable {
    case coffee = "Coffee"
    case cake = "Cake"
    case tea = "Tea"
    case snacks = "Snacks"
}

extension MenuCategory: CustomDebugStringConvertible {
    public var debugDescription: String {
        rawValue
    }
}

public extension MenuCategory {
    static func get(by name: String) -> Self? {
        allCases.first { $0.rawValue == name }
    }
}

// MARK: - Identifiable

extension MenuCategory: Identifiable {
    public var id: String { self }
}

// MARK: - Sendable

extension MenuCategory: Sendable {}
