//
//  File.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 15.05.25.
//

import CoffeeKit
import Foundation
import XCTest
import FoundationKit
import AuthenticationKit
import ProductKit
import OrderKit
import ImageKit

@MainActor
final class MenuManagerTests: XCTestCase {
    let menuManager = MenuManager(from: WebserviceProvider(inMode: .dev))

    func testItemSequence() {
        let itemSequence = menuManager.productService
        XCTAssertNotNil(itemSequence)
    }
}
