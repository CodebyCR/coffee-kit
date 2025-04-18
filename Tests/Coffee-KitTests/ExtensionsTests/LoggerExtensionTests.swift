//
//  LoggerExtensionTests.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 18.04.25.
//

@testable import Coffee_Kit
import OSLog
import Foundation
import XCTest


public final class LoggerExtensionTests: XCTestCase {

    enum TestError: Error {
        case exampleThrow
    }

    func testTrackSucessfulTask(){
        let logger = Logger()


        logger.trackTask(called: "SuccessTestTask") {
            Thread.sleep(forTimeInterval: 1)
            XCTAssertTrue(true)
        }
    }

    func testTrackFailedTask(){
        let logger = Logger()

        logger.trackTask(called: "FailedTestTask") {
            Thread.sleep(forTimeInterval: 1)
            throw TestError.exampleThrow
        }
    }
}
