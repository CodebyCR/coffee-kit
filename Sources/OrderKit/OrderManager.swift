//
//  OrderManager.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 04.12.24.
//

import Foundation
import OSLog
import FoundationKit
import AuthenticationKit
import ProductKit

@Observable
public final class OrderManager {
    @ObservationIgnored private var logger = Logger(subsystem: "com.CodebyCR.coffeeKit", category: "OrderManager")
    @ObservationIgnored private var webservice: WebserviceProvider
    @ObservationIgnored private var orderService: OrderService

    
    public var orderHistory: [Order] = []
    public var pendingOrderId: UUID?
    
    public var isFetchingHistory: Bool = false
    public var hasReachedEnd: Bool = false

    public init(from webservice: WebserviceProvider) {
        self.webservice = webservice
        self.orderService = OrderService(webserviceProvider: webservice)
    }
    
    public var containsOrder: Bool {
        return pendingOrderId != nil
    }

    public func takeOrder(from orderBuilder: OrderBuilder) -> Result<String, Error> {
        logger.info("Ordering...")

        do {
            let newOrder = try orderBuilder.build()
            pendingOrderId = newOrder.id
            takeOrder(newOrder)
            return .success("Your order will arrive soon.")

        } catch {
            logger.error("Order could not be created. \(error.localizedDescription)")
            return .failure(error)
        }
    }

    private func takeOrder(_ order: Order) {
        logger.info("\(order.debugDescription)")

        Task(name: "Take Order", priority: .userInitiated) {
            do {
                try await orderService.takeOrder(order)
                pendingOrderId = order.id

            } catch {
                logger.error("Error taking order: \(error)")
            }
        }
    }

    public func getRealTimeOrderStatus(by id: String) throws -> AsyncThrowingStream<URLSessionWebSocketTask.Message, Error> {
        guard !id.isEmpty else {
            throw FetchError.invalidRequest
        }

        guard let orderStatusUrl = URL(string: "\(webservice.databaseAPI.socketURL)/order/status/\(id)") else {
            throw FetchError.invalidRequest
        }

        guard let websocketService = try? WebsocketConnection(url: orderStatusUrl) else {
            throw FetchError.invalidRequest
        }

        return websocketService.receive()
    }
    
    /// Load the order history for the user.
    /// This method  feched 20 orders at a time and appends them to the `completedOrders`. (Keyset pagination)
    public func loadOrderHistory(before date: Date? = nil) async {
        if isFetchingHistory {
            logger.info("loadOrderHistory: Already fetching, skipping.")
            return
        }
        if hasReachedEnd {
            logger.info("loadOrderHistory: Already reached end, skipping.")
            return
        }
        
        isFetchingHistory = true
        defer { isFetchingHistory = false }
        
        let lastOrderDate = date ?? .now
        logger.info("loadOrderHistory: Fetching orders before \(lastOrderDate)")
        
        do {
            let fetchedOrders = try await orderService.fetchOrderHistory(before: lastOrderDate)
            logger.info("loadOrderHistory: API returned \(fetchedOrders.count) orders")
            
            if fetchedOrders.isEmpty {
                logger.info("loadOrderHistory: No orders returned, setting hasReachedEnd = true")
                hasReachedEnd = true
                return
            }
            
            // Keyset pagination: if we get fewer than expected, we reached the end
            if fetchedOrders.count < 20 {
                logger.info("loadOrderHistory: Received less than 20 orders, setting hasReachedEnd = true")
                hasReachedEnd = true
            }
            
            // Append only new orders to avoid duplicates
            let existingIds = Set(orderHistory.map(\.id))
            let newOrders = fetchedOrders.filter { !existingIds.contains($0.id) }
            
            orderHistory.append(contentsOf: newOrders)
            logger.info("loadOrderHistory: Added \(newOrders.count) new orders. Total: \(self.orderHistory.count)")
        }
        catch {
            logger.error("loadOrderHistory Error: \(error)")
        }
    }
    
    public func getOrder(by id: UUID) async throws -> Order{
        return try await orderService.getOrder(by: id)
    }
}


