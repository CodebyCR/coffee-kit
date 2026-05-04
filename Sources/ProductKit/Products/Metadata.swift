//
//  Metadata.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 23.12.24.
//
import Foundation

nonisolated public struct Metadata: Sendable, Codable, Hashable, CustomDebugStringConvertible {
    let createdAt: Date
    let updatedAt: Date
    //let tagIds: [String]
    public var debugDescription: String {
        get {
            return "Metadata: createdAt=\(createdAt), updatedAt=\(updatedAt)"
        }
    }

    // MARK: - Codable

    public init() {
        createdAt = Date()
        updatedAt = Date()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let createdAtTimeinterval = try? container.decode(TimeInterval.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: createdAtTimeinterval ?? Date.now.timeIntervalSince1970)
        let updatedAtTimeinterval = try? container.decode(TimeInterval.self, forKey: .updatedAt)
        updatedAt = Date(timeIntervalSince1970: updatedAtTimeinterval ?? Date.now.timeIntervalSince1970)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(createdAt.timeIntervalSince1970, forKey: .createdAt)
        try container.encode(updatedAt.timeIntervalSince1970, forKey: .updatedAt)
        //try container.encode(tagIds, forKey: .tagIds)
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case tagIds = "tag_ids"
    }

}
