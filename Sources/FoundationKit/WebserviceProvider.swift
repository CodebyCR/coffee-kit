//
//  Webservice.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation

public protocol Authenticating: Sendable {
    func authenticate(_ request: inout URLRequest) async
}

public struct WebserviceProvider {
    public let databaseAPI: DatabaseAPI
    public let authManager: (any Authenticating)?

    public init(inMode databaseAPI: consuming DatabaseAPI, authManager: (any Authenticating)? = nil) {
        self.databaseAPI = databaseAPI
        self.authManager = authManager
    }
}
