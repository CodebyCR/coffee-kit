//
//  OrderManager.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 04.12.24.
//

import Foundation
import OSLog

@Observable
public final class OrderManager {
    @ObservationIgnored private var logger = Logger(subsystem: "com.CodebyCR.coffeeKit", category: "OrderManager")
    @ObservationIgnored private var webservice: WebserviceProvider
    @ObservationIgnored private var orderService: OrderService

    private(set) var pendingOrders: [Order] = []
    public var orderHistory: [Order] = []
    public var currentOrder: Order? { pendingOrders.first }

    public init(from webservice: WebserviceProvider) {
        self.webservice = webservice
        self.orderService = webservice.orderService
    }

    public func takeOrder(from orderBuilder: OrderBuilder) -> Result<String, Error> {
        logger.info("Ordering...")

        do {
            let newOrder = try orderBuilder.build()
            pendingOrders.append(newOrder)
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
                pendingOrders.append(order)

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
    public func loadOrderHistory(before date: Date = .now) async {
        let lastOrderDate = date
        
        do {
            let fetchedOrders = await try orderService.fetchOrderHistory(before: lastOrderDate)
            print("Fetched \(fetchedOrders.count) orders")
            orderHistory.append(contentsOf: fetchedOrders)
        }
        catch {
            logger.error("""
                        Error in '\(#function)': 
                        \(error)   
                        """)
        }
    }
}
