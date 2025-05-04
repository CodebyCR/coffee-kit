//
//  OrderTests.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 30.12.24.
//

@testable import Coffee_Kit
import Foundation
import XCTest
import OSLog

@MainActor
final class OrderTests: XCTestCase {
    
    let logger = Logger(subsystem: "com.CodebyCR.coffeeKit", category: "OrderTests")


    func testTakingOrder() async {
        await logger.trackTask(called: "testTakingOrder") {
            let testUserId = UUID(uuidString: "03F35975-AF57-4691-811F-4AB872FDB51B")!
            let databaseAPI = DatabaseAPI.dev
            let webservice =  WebserviceProvider(inMode: databaseAPI)
            let orderManager = OrderManager(from: webservice)

            let orderBuilder = OrderBuilder(for: testUserId)
            orderBuilder.addProduct(Product())
            orderBuilder.addProduct(Product())

            guard let newValidOrder = orderBuilder.build() else {
                logger.error("Failed to take order")
                return
            }

            orderManager.takeOrder(newValidOrder)

        }
    }

    func testDecodeOrder() {
        let orderJson = """
        {
            "user_id": "8BC6A8B8-302F-40BA-B54C-B9722E72BCD4",
            "payment_option": "Cash",
            "id": "FBD9F6AF-8844-4598-845F-88148C9691D4",
            "items": [
                {
                    "id": "EA412375-BC6D-4843-94A0-0499F222595D",
                    "quantity": 2
                }
            ],
            "order_date": 765311164.172788,
            "payment_status": "pending",
            "order_status": "ordered"
        }
        """

        let jsonData = orderJson.data(using: .utf8)!
        let order = try! JSONDecoder().decode(Order.self, from: jsonData)

        XCTAssertEqual(order.id, UUID(uuidString: "FBD9F6AF-8844-4598-845F-88148C9691D4"))
    }
}
