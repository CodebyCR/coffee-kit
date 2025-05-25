//
//  File.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 15.05.25.
//

import Foundation
import XCTest

@testable import Coffee_Kit

@MainActor
final class MenuManagerTests: XCTestCase {
    let menuManager = MenuManager(from: WebserviceProvider(inMode: .dev))

    func testItemSequence() {
        let itemSequence = menuManager.productService
        XCTAssertNotNil(itemSequence)
    }
}
