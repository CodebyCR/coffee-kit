//
//  WeakSelfTests.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 08.05.25.
//

@testable import Coffee_Kit
import Foundation
import Harmonize
import OSLog
import XCTest

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

    public func testClassNamingConvention() throws {
        let message = "Class name violate the naming convention."

        let candidates = Harmonize
            .productionCode()
            .classes()
            .withoutSuffix(
                "ViewModel",
                "Service",
                "Manager",
                "Builder"
            )

        if candidates.isNotEmpty {
            print("Found \(candidates.count) candidates for naming convention violations.")
        }

        for _ in candidates {
            XCTAssert(false, message)
        }
    }
}
