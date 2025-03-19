//
//  Webservice.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation

@MainActor
public struct WebserviceProvider{
    public let databaseAPI: DatabaseAPI

    public init(inMode databaseAPI: consuming DatabaseAPI) {
        self.databaseAPI = databaseAPI
    }

    public var orderService: OrderService {
        return OrderService(databaseAPI: databaseAPI)
    }



}
