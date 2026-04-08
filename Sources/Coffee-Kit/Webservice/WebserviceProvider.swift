//
//  Webservice.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation
import Authentication_Kit

public struct WebserviceProvider{
    public let databaseAPI: DatabaseAPI
    public let authManager: AutenticationManager?

    public init(inMode databaseAPI: consuming DatabaseAPI, authManager: AutenticationManager? = nil) {
        self.databaseAPI = databaseAPI
        self.authManager = authManager
    }

    public var orderService: OrderService {
        return OrderService(databaseAPI: databaseAPI, authManager: authManager)
    }
    
    public var productService: ProductService {
        return ProductService(databaseAPI: databaseAPI, authManager: authManager)
    }

}
