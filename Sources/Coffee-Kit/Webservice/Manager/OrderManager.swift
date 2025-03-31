//
//  OrderManager.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 04.12.24.
//

import Foundation

@MainActor
@Observable public final class OrderManager {
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
        Task {
            do {
                try await orderService.takeOrder(order)
                pendingOrders.append(order)

            } catch {
                print("Error taking order: \(error)")
            }
        }
    }
}
