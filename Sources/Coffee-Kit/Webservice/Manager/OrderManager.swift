//
//  OrderManager.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 04.12.24.
//

import Foundation
import OSLog

@MainActor
@Observable public final class OrderManager {
    @ObservationIgnored private var logger = Logger(subsystem: "com.CodebyCR.coffeeKit", category: "OrderManager")
    @ObservationIgnored private var webservice: WebserviceProvider

    private(set) var pendingOrders: [Order] = []
    private(set) var completedOrders: [Order] = []

    public init(from webservice: WebserviceProvider) {
        self.webservice = webservice
    }

    public var orderService: OrderService {
        OrderService(databaseAPI: webservice.databaseAPI)
    }

    public func takeOrder(_ order: Order) {
        logger.info("\(order.debugDescription)")

        Task {
            do {
                try await orderService.takeOrder(order)
                pendingOrders.append(order)

            } catch {
                logger.error("Error taking order: \(error)")
            }
        }
    }
}
