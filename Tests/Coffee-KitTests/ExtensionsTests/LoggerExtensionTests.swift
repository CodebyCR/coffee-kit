//
//  LoggerExtensionTests.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 18.04.25.
//

@testable import Coffee_Kit
import Foundation
import OSLog
import XCTest

public final class LoggerExtensionTests: XCTestCase {
    enum TestError: Error {
        case exampleThrow
    }

    func testTrackSucessfulTask() async {
        let logger = Logger()

        await logger.trackTask(called: "SuccessTestTask") {
            try await Task.sleep(for: .seconds(1))
            XCTAssertTrue(true)
        }
    }

    func testTrackFailedTask() async {
        let logger = Logger()

        await logger.trackTask(called: "FailedTestTask") {
            try await Task.sleep(for: .seconds(1))
            throw TestError.exampleThrow
        }
    }
}
