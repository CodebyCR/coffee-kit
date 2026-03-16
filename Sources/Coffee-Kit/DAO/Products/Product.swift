//
//  CakeModel.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 27.12.24.
//

import Foundation

public struct Product {
    private var storage: Storage
    
    // MARK: - Storage Class für Copy-on-Write
    
    private final class Storage {
        let id: UUID
        let category: String
        let categoryNumber: UInt16
        let name: String
        let price: Float64
        let imageName: String
        let metadata: Metadata
        
        init(id: UUID,
             category: String,
             categoryNumber: UInt16,
             name: String,
             price: Float64,
             imageName: String,
             metadata: Metadata
        ) {
            self.id = id
            self.category = category
            self.categoryNumber = categoryNumber
            self.name = name
            self.price = price
            self.imageName = imageName
            self.metadata = metadata
        }
    }
    
    // MARK: - Public Properties (read-only)
    
    public var id: UUID { storage.id }
    public var category: String { storage.category }
    public var categoryNumber: UInt16 { storage.categoryNumber }
    public var name: String { storage.name }
    public var price: Float64 { storage.price }
    public var imageName: String { storage.imageName }
    public var metadata: Metadata { storage.metadata }
    
    // MARK: - Initializer
    
    public init(id: UUID, category: String, categoryNumber: UInt16, name: String,
                price: Float64, imageName: String, metadata: Metadata) {
        self.storage = Storage(id: id, category: category, categoryNumber: categoryNumber,
                              name: name, price: price, imageName: imageName, metadata: metadata)
    }
}

// MARK: - Default Init

public extension Product {
    init() {
        self.init(
            id: UUID(),
            category: "Coffee",
            categoryNumber: 1,
            name: "Caffee",
            price: 3.20,
            imageName: "Mocha.png",
            metadata: Metadata()
        )
    }
}

// MARK: - Computed Properties

public extension Product {
    var imageUrl: URL? {
        URL(string: "http://127.0.0.1:8080/test/images/\(category)/\(imageName)")
    }
}

// MARK: - Identifiable

extension Product: Identifiable {}

// MARK: - Sendable

extension Product: Sendable {}

// MARK: - CustomStringConvertible

extension Product: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        CoffeeModel:
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

extension Product: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case category
        case categoryNumber = "category_number"
        case name
        case price
        case imageName = "image_name"
        case metadata
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let category = try container.decode(String.self, forKey: .category)
        let categoryNumber = try container.decode(UInt16.self, forKey: .categoryNumber)
        let name = try container.decode(String.self, forKey: .name)
        let price = try container.decode(Float64.self, forKey: .price)
        let imageName = try container.decode(String.self, forKey: .imageName)
        let metadata = try container.decode(Metadata.self, forKey: .metadata)
        
        self.init(id: id, category: category, categoryNumber: categoryNumber,
                 name: name, price: price, imageName: imageName, metadata: metadata)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(category, forKey: .category)
        try container.encode(categoryNumber, forKey: .categoryNumber)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(metadata, forKey: .metadata)
    }
}

// MARK: - Hashable

extension Product: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
    public static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }
}
