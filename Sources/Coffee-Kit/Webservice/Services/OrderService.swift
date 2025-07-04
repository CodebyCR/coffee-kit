//
//  OrderService.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 22.01.25.
//

import Foundation
import OSLog

@MainActor
public struct OrderService {
    // MARK: - Properties

    private let logger = Logger(subsystem: "com.CodebyCR.coffeeKit", category: "OrderService")
    private let orderUrl: URL
    private let urlSession: URLSession

    // MARK: - Initializer

    init(databaseAPI: borrowing DatabaseAPI) {
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForRequest = 14
        urlSessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad

        self.urlSession = URLSession(configuration: urlSessionConfiguration)
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

        logger.debug("Post to \(createOrderURL)")

        let (_, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200 ..< 300 ~= httpResponse.statusCode
        else {
            let requestDataJson = String(data: requestData, encoding: .utf8) ?? "nil"

            print(requestDataJson)
            logger.error("""
            Error in \(#file)
            \t\(#function) \(#line):\(#column)
            \tStatus code: \((response as? HTTPURLResponse)?.statusCode ?? 0)
            """)

            throw FetchError.invalidResponse
        }
    }

    public func getOrder(by id: String) async throws -> Order {
        let orderByIdUrl = orderUrl / "id/\(id)"
        let (data, response) = try await urlSession.data(from: orderByIdUrl)

        guard let order = try? JSONDecoder().decode(Order.self, from: data) else {
            print(response)
            print("""
            Error in \(#file)
            \t\(#function) \(#line):\(#column)
            \tStatus code: \((response as? HTTPURLResponse)?.statusCode ?? 0)
            """)
            throw FetchError.decodingError
        }

        return order
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
