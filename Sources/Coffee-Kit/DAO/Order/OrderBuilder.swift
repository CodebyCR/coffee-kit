//
//  OrderBuilder.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 06.03.25.
//

import Foundation

@Observable
public class OrderBuilder {
    // MARK: - Properties

    private(set) var userId: UUID
    public var products: [OrderProduct] = []

    public var totalProducts: Int {
        products.reduce(0) { Int($0) + Int($1.quantity) }
    }

    public var totalAmount: Float64 {
        products.reduce(0) { $0 + $1.product.price * Float64($1.quantity) }
    }

    // MARK: - Initializer

    /// Build new Order
    public init(for userId: UUID) {
        self.userId = userId
    }

//    /// Init from existing Order
//    public init(use order: Order) {
//        self.userId = order.userId
//        self.products = order.items
//    }

    // MARK: - Methods

    public func addProduct(_ product: Product, quantity: UInt8) {
        products.append(OrderProduct(product: product, quantity: quantity))
    }

    public func addProduct(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].quantity += 1
        } else {
            addProduct(product, quantity: 1)
        }
    }

    public func removeProduct(_ product: Product) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            if products[index].quantity > 1 {
                products[index].quantity -= 1
            } else {
                products.remove(at: index)
            }
        }
    }

    public func removeAll(_ product: Product) {
        products.removeAll { $0.id == product.id }
    }

    public func build() -> Order? {
        guard !products.isEmpty else {
            return nil
        }

        let orderItems = products.map { OrderItem(from: $0) }

        // Currently fake user id and only cash payment is supported
        let newOrder = Order(userId: UUID(), orderdProducts: orderItems, paymentOption: .cash)
        products.removeAll()

        return newOrder
    }
}
