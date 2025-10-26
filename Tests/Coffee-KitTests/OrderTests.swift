//
//  OrderTests.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 30.12.24.
//

@testable import Coffee_Kit
import Combine
import Foundation
import OSLog
import XCTest

@MainActor
final class OrderTests: XCTestCase {
    let logger = Logger(subsystem: "com.CodebyCR.coffeeKit", category: "OrderTests")

    func testTakingOrder() async {
        await logger.trackTask(called: "testTakingOrder") {
            let testUserId = UUID(uuidString: "03F35975-AF57-4691-811F-4AB872FDB51B")!
            let databaseAPI = DatabaseAPI.dev
            let webservice = WebserviceProvider(inMode: databaseAPI)
            let orderManager = OrderManager(from: webservice)

            let orderBuilder = OrderBuilder(for: testUserId)
            orderBuilder.addProduct(Product())
            orderBuilder.addProduct(Product())

            let result = orderManager.takeOrder(from: orderBuilder)

            switch result {
            case .success(let message):
                print("Order result: \(message)")
                XCTAssertEqual(message, "Your order will arrive soon.")
            case .failure(let error):
                print("Order failed with error: \(error)")
                XCTAssertNoThrow(error)
            }
        }
        // Delete test order
    }

    func testDecodeOrder() {
        let orderJson = """
        {
            "user_id": "03F35975-AF57-4691-811F-4AB872FDB51B",
            "items": [
                {
                    "id": "01dc289a-4bb0-407c-b5a6-a6a868ab0101",
                    "quantity": 1
                },
                {
                    "id": "25e604dc-3308-484b-873d-0491d5ad4e9d",
                    "quantity": 1
                },
                {
                    "id": "e074867a-0c6a-49ff-87ca-b1ba5dae5236",
                    "quantity": 1
                },
                {
                    "id": "3cfc8e2b-95b1-461c-a84b-21215dee5a7f",
                    "quantity": 1
                }
            ],
            "payment_status": "pending",
            "order_date": 765311164.172788,
            "payment_option": "Cash",
            "id": "611C357B-50B7-4773-9D7A-BB3349975C9D",
            "order_status": "ordered"
        }
        """

        let jsonData = orderJson.data(using: .utf8)!
        let order = try! JSONDecoder().decode(Order.self, from: jsonData)

        XCTAssertEqual(order.id, UUID(uuidString: "611C357B-50B7-4773-9D7A-BB3349975C9D"))
    }

    func testFetchOrderById() async throws {
        let orderId = "059621D5-C191-45A9-AB5B-B4B414E9DB17"
        let databaseAPI = DatabaseAPI.dev
        let webservice = WebserviceProvider(inMode: databaseAPI)
        let orderService = OrderService(databaseAPI: webservice.databaseAPI)

        // Warmup
        _ = try? await orderService.getOrder(by: orderId)

        // Jetzt messen
        let start = Date()

        for _ in 0 ..< 10 {
            let order = try await orderService.getOrder(by: orderId)
            XCTAssertNotNil(order, "Order should not be nil")
            XCTAssertEqual(order.id.uuidString, orderId, "Order ID should match")
        }

        let duration = Date().timeIntervalSince(start)
        let average = duration / 10.0
        print("Average time per fetch: \(average) seconds")
    }
}
