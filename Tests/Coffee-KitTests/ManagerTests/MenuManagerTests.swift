//
//  File.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 15.05.25.
//

import Foundation
import XCTest
import FoundationKit
import AuthenticationKit
import ProductKit
import OrderKit
import ImageKit

@MainActor
final class MenuManagerTests: XCTestCase {

    func testItemSequence() {
        let keychain = DefaultKeychainManager()
        let databaseAPI: DatabaseAPI = .dev
        let authenticationManager = AutenticationManager(keychain: keychain, databaseAPI: databaseAPI)
        let webserviceProvider = WebserviceProvider(inMode: databaseAPI, autheticationManager: authenticationManager)
        let menuManager = MenuManager(from: webserviceProvider)
        let itemSequence = menuManager.productService
        XCTAssertNotNil(itemSequence)
    }
}
