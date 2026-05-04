//
//  Webservice.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation

public struct WebserviceProvider {
    public let databaseAPI: DatabaseAPI
    public let autheticationManager: AutenticationManager

    public init(
        inMode databaseAPI: consuming DatabaseAPI,
        autheticationManager: AutenticationManager
    ) {
        self.databaseAPI = databaseAPI
        self.autheticationManager = autheticationManager
    }
}
