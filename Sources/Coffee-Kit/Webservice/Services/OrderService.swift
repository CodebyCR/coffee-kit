//
//  OrderService.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 22.01.25.
//

import Foundation

@MainActor
public struct OrderService {
    // MARK: - Properties

    private let orderUrl: URL

    // MARK: - Initializer

    init(databaseAPI: borrowing DatabaseAPI) {
        self.orderUrl = databaseAPI.baseURL / "order"
    }

    // MARK: - Methods

    public func takeOrder(_ newOrder: Order) async throws {
        let createOrderURL = orderUrl / "id/\(newOrder.id)"
        let requestData = try JSONEncoder().encode(newOrder)
        var request = URLRequest(url: createOrderURL)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("Post to \(createOrderURL)")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200 ..< 300 ~= httpResponse.statusCode
        else {
            let requestDataJson = String(data: requestData, encoding: .utf8) ?? "nil"

            print(requestDataJson)
            print("""
            Error in \(#file)
            \t\(#function) \(#line):\(#column)
            \tStatus code: \((response as? HTTPURLResponse)?.statusCode ?? 0)
            """)
            throw FetchError.invalidResponse
        }
    }

//    public func create(new order: Order) async throws {
//        let orderJSON = try JSONEncoder().encode(order)
//        let createOrderURL = orderUrl / "order" / "\(order.id)"
//        var request = URLRequest(url: createOrderURL)
//        request.httpMethod = "POST"
//        request.httpBody = orderJSON
//
//        let (_, response) = try await URLSession.shared.data(for: request)
//
//        guard let httpResponse = response as? HTTPURLResponse,
//              httpResponse.statusCode == 201
//        else {
//            print("""
//            Error in \(#file)
//            \t\(#function) \(#line):\(#column)
//            \tStatus code: \((response as? HTTPURLResponse)?.statusCode ?? 0)
//            """)
//            throw FetchError.invalidResponse
//        }
//    }
}
