//
//  User.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 13.07.25.
//

import Foundation

public struct User: Identifiable {
    public let id: UUID
    public let name: String
    public let email: String
}

// MARK: - Sendable
extension User: Sendable {}

// MARK: - Codable
extension User: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
    }
}

// MARK: - CustomDebugStringConvertible
extension User: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        User:
            id=\(id),
            name=\(name),
            email=\(email)
        """
    }
}

// MARK: - Hashable
extension User: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.email == rhs.email
    }
}

struct LoginResponse: Codable {
    let token: String
}

