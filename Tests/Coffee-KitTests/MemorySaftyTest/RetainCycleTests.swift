//
//  RetainCycleTests.swift
//  Coffee-Kit
//
//  Created by Gemini on 07.05.26.
//

import Foundation
import Harmonize
import XCTest

/// Tests to ensure memory safety and prevent retain cycles in the Coffee-Kit project.
final class RetainCycleTests: XCTestCase {
    
    /// Verifies that all closures within classes that reference 'self' do so weakly.
    /// This prevents common retain cycles where a class instance captures itself strongly in an escaping closure.
    func testClosuresShouldCaptureSelfWeaklyToPreventRetainCycles() throws {
        // Scan the production code for potential memory leaks
        Harmonize.productionCode()
            .classes()
            .functions()
            .closures()
            .filter(\.hasSelfReference)
            .assertTrue(message: "Retain cycle detected: closure captures 'self' strongly. Use '[weak self]' to prevent memory leaks.") { closure in
                closure.isCapturingWeak(valueOf: "self")
            }
    }
}
