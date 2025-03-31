//
//  OrderTests.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 30.12.24.
//

@testable import Coffee_Kit
import Foundation
import XCTest

final class OrderTests: XCTestCase {
    func testTakingOrder() async {
        let databaseAPI = DatabaseAPI.dev
        let webservice = await WebserviceProvider(inMode: databaseAPI)
        _ = await OrderManager(from: webservice)
//
//        var products = orderManager.shoppingCard
//        products.add( CakeModel(), to: "Cakes")
//        products.add( CoffeeModel(), to: "Coffees")
//        products.add( CakeModel(), to: "Cakes")
//
//        let json = try! JSONEncoder().encode(products)
//        print(json)
//
//        await orderManager.takeOrder()
    }


}
