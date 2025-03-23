//
//  Order.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 04.12.24.
//
import Foundation

public struct Order {
    public let id: UUID
    public let userId: UUID
    public let orderDate: Date
    public let orderStatus: String
    public let paymentOption: String
    public let paymentStatus: String
    public let items: [OrderItem]

    public var orderDateAsFloat64: Float64 {
        Float64(orderDate.timeIntervalSince1970)
    }
}

// MARK: - Initializer

public extension Order {
    init() {
        // demo
        id = UUID(uuidString: "2E2F208E-9EBB-4B40-801D-BDD5859858C3")!
        userId = UUID(uuidString: "03F35975-AF57-4691-811F-4AB872FDB51B")!
        orderDate = Date(timeIntervalSince1970: 763811237.81686)
        orderStatus = "ordered"
        paymentOption = "Cash"
        paymentStatus = "pending"
        items = [
            OrderItem(id: UUID(uuidString: "D607034C-94BE-4225-8275-D960E88020C9")!, quantity: 2)
        ]
    }

    init(userId: UUID, orderdProducts: [OrderItem], paymentOption: PaymentOption) {
        id = UUID()
        self.userId = userId
        orderDate = Date.now
        orderStatus = "ordered"
        self.paymentOption = paymentOption.rawValue
        paymentStatus = "pending"
        items = orderdProducts
    }
}

// MARK: - Identifiable

extension Order: Identifiable {}

// MARK: - Sendable

extension Order: Sendable {}

// MARK: - CustomDebugStringConvertible

extension Order: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        Order:
            id=\(id),
            userId=\(userId),
            orderDate=\(orderDate),
            orderStatus=\(orderStatus),
            paymentOption=\(paymentOption),
            paymentStatus=\(paymentStatus),
            items=\(items)
        """
    }
}

// MARK: - Codeable

extension Order: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case orderDate = "order_date"
        case orderStatus = "order_status"
        case paymentOption = "payment_option"
        case paymentStatus = "payment_status"
        case items
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        let rawOrderDate = try container.decode(Float64.self, forKey: .orderDate)
        orderDate = Date(timeIntervalSince1970: rawOrderDate)
        orderStatus = try container.decode(String.self, forKey: .orderStatus)
        paymentOption = try container.decode(String.self, forKey: .paymentOption)
        paymentStatus = try container.decode(String.self, forKey: .paymentStatus)
        items = try container.decode([OrderItem].self, forKey: .items)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(orderDate, forKey: .orderDate)
        try container.encode(orderStatus, forKey: .orderStatus)
        try container.encode(paymentOption, forKey: .paymentOption)
        try container.encode(paymentStatus, forKey: .paymentStatus)
        try container.encode(items, forKey: .items)
    }
}
