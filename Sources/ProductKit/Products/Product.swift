//
//  CakeModel.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 27.12.24.
//

import Foundation
import FoundationKit

// MARK: - Main Struct

nonisolated public struct Product {
    public let id: UUID
    public let category: String
    public let categoryNumber: UInt16
    public let name: String
    public let price: Float64
    public let imageName: String
    public let metadata: Metadata
    
}

// MARK: - Initializer

nonisolated public extension Product {
    
    init() {
        self.id = UUID()
        self.category =  "Coffee"
        self.categoryNumber = 1
        self.name = "Caffee"
        self.price = 3.20
        self.imageName = "Mocha.png"
        self.metadata = Metadata()
    }

}

// MARK: - Computed Properties

public extension Product {
    func imageUrl(relativeTo imageURL: URL) -> URL {
        let newImageName = imageName.replacing(".png", with: ".heic")
        return imageURL / category / newImageName
    }
}

// MARK: - Identifiable

nonisolated extension Product: Identifiable {}

// MARK: - Sendable

nonisolated extension Product: Sendable {}

// MARK: - CustomDebugStringConvertible

nonisolated extension Product: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        Product:
            id=\(id),
            category=\(category),
            categoryNumber=\(categoryNumber),
            name=\(name),
            price=\(price),
            imageName=\(imageName),
            metadata=\(metadata)
        """
    }
}

// MARK: - Codable

nonisolated extension Product: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case categoryNumber = "category_number"
        case name
        case price
        case imageName = "image_name"
        case metadata
    }
}

// MARK: - Hashable & Equatable

nonisolated extension Product: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }
}
