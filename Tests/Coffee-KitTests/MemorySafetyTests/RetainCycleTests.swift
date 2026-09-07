//
//  RetainCycleTests.swift
//  Coffee-Kit
//
//  Created by Gemini on 07.05.26.
//

import Foundation
import Harmonize
import Testing

@Suite("Retain Cycle Tests")
struct RetainCycleTests {
    
    @Test("Closures should capture 'self' weakly to prevent retain cycles")
    func closuresShouldCaptureSelfWeaklyToPreventRetainCycles() throws {
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
