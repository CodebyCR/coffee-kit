//
//  OrderService.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 22.01.25.
//

import Foundation
import OSLog
import Authentication_Kit

public struct OrderService {
    // MARK: - Properties

    private let logger = Logger(subsystem: "com.CodebyCR.coffeeKit", category: "OrderService")
    private let orderUrl: URL
    private let urlSession: URLSession
    private let authManager: AutenticationManager?

    // MARK: - Initializer

    init(databaseAPI: borrowing DatabaseAPI, authManager: AutenticationManager? = nil) {
        let urlSessionConfiguration = URLSessionConfiguration.default
        urlSessionConfiguration.timeoutIntervalForRequest = 14

        self.urlSession = URLSession(configuration: urlSessionConfiguration)
        self.orderUrl = databaseAPI.baseURL / "order"
        self.authManager = authManager
    }

    // MARK: - Methods

    public func takeOrder(_ newOrder: Order) async throws {
        let createOrderURL = orderUrl / "id" / "\(newOrder.id)"
        let requestData = try JSONEncoder().encode(newOrder)
        var request = URLRequest(url: createOrderURL)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authentication
        if let authManager = authManager {
            await authManager.authenticate(&request)
        }

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

    public func getOrder(by id: UUID) async throws -> Order {
        let orderByIdUrl = orderUrl / "id" / "\(id)"
        var request = URLRequest(url: orderByIdUrl)
        
        // Authentication
        if let authManager = authManager {
            await authManager.authenticate(&request)
        }
        
        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200 ..< 300 ~= httpResponse.statusCode else {
            logger.error("""
            Error in \(#file)
            \t\(#function) \(#line):\(#column)
            \tStatus code: \((response as? HTTPURLResponse)?.statusCode ?? 0)
            """)
            throw FetchError.invalidResponse
        }

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
    
    /// Load the order history for the user.
    /// This method  feched 20 orders at a time and appends them to the `completedOrders`. (Keyset pagination)
    public func fetchOrderHistory(before lastOrderDate: Date = .now) async throws -> [Order] {
        let unixTimestamp = Int(lastOrderDate.timeIntervalSince1970)
        let orderHistoryUrl = orderUrl / "history" / "\(unixTimestamp)"
        var request = URLRequest(url: orderHistoryUrl)
        
        // Authentication
        if let authManager = authManager {
            await authManager.authenticate(&request)
        }
        
        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200 ..< 300 ~= httpResponse.statusCode else {
            logger.error("""
            Error in \(#file)
            \t\(#function) \(#line):\(#column)
            \tStatus code: \((response as? HTTPURLResponse)?.statusCode ?? 0)
            """)
            throw FetchError.invalidResponse
        }

        guard let orders = try? JSONDecoder().decode([Order].self, from: data) else {
            print(response)
            print("""
            Error in \(#file)
            \t\(#function) \(#line):\(#column)
            \tStatus code: \((response as? HTTPURLResponse)?.statusCode ?? 0)
            """)
            throw FetchError.decodingError
        }

        return orders
    }

}
