//
//  MenuManagerTests.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 15.05.25.
//

import Foundation
import Testing
import FoundationKit
import AuthenticationKit
import ProductKit
import OrderKit
import ImageKit

@Suite("Menu Manager Tests")
@MainActor
struct MenuManagerTests {

    @Test("Test item sequence", .requiresAPI)
    func itemSequence() throws {
        
        let keychain = DefaultKeychainManager()
        let databaseAPI: DatabaseAPI = .dev
        let authenticationManager = AutenticationManager(keychain: keychain, databaseAPI: databaseAPI)
        let webserviceProvider = WebserviceProvider(inMode: databaseAPI, autheticationManager: authenticationManager)
        let menuManager = MenuManager(from: webserviceProvider)
        #expect(menuManager.items.isEmpty, "A freshly created menu manager has no items yet")
    }
}
