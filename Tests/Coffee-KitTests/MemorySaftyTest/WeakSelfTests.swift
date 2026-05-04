//
//  WeakSelfTests.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 08.05.25.
//

import Foundation
import Harmonize
import OSLog
import XCTest
import FoundationKit
import AuthenticationKit
import ProductKit
import OrderKit
import ImageKit

final class WeakSelfTests: XCTestCase {
    let logger = Logger()

    public func testShouldCaptureSelfWeaklyOnViewModels() throws {
        let message = "'self' should capture weakly in closures at this place."
        let memoryLeakCanidates = Harmonize
            .productionCode()
            .classes()

        print("Found \(memoryLeakCanidates.count) candidates for memory leaks.")
        print("Classes: \(memoryLeakCanidates.map(\.name))")

        memoryLeakCanidates
            .functions()
            .filter(\.hasAnyClosureWithSelfReference)
            .assertTrue(message: message) {
                $0.closures()
                    .filter(\.hasSelfReference)
                    .allSatisfy { $0.isCapturingWeak(valueOf: "self") }
            }
    }

}
