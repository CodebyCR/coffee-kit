//
//  XCTestCase+APITests.swift
//  Coffee-Kit
//

import XCTest

extension XCTestCase {
    /// Returns true if API-dependent tests should be run.
    /// This is controlled by the environment variable `RUN_API_TESTS=1`.
    var shouldRunAPITests: Bool {
        ProcessInfo.processInfo.environment["RUN_API_TESTS"] == "1"
    }

    /// Skips the test unless API-dependent tests are enabled.
    func skipUnlessAPITestsEnabled() throws {
        try XCTSkipUnless(shouldRunAPITests, "Skipping API-dependent test. Set RUN_API_TESTS=1 to enable.")
    }
}
