
import Foundation

nonisolated public struct User: Identifiable {
    public let id: UUID
    public let name: String
    public let email: String
    public let token: String
    
    public init(id: UUID = UUID(), email: String, name: String, token: String) {
        self.id = id
        self.email = email
        self.name = name
        self.token = token
    }

}

// MARK: - Sendable
extension User: Sendable {}

// MARK: - Codable
nonisolated extension User: Codable {
    nonisolated enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case token
    }

    nonisolated public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        token = try container.decode(String.self, forKey: .token)
    }

    nonisolated public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(token, forKey: .token)
    }
}

// MARK: - CustomDebugStringConvertible
extension User: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        User:
            id=\(id),
            name=\(name),
            email=\(email),
            token=\(token)
        """
    }
}

// MARK: - Hashable
extension User: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.email == rhs.email && lhs.token == rhs.token
    }
}


