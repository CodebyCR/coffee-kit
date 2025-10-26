//
//  WebsocketConnectionTest.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 25.10.25.
//

@testable import Coffee_Kit
import Foundation
import XCTest

@MainActor
final class WebsocketConnectionTest: XCTestCase {
    func testWebsocketConnectionOrderStatus() async throws {
        let url = URL(string: "ws://127.0.0.1:8080/test/order/status/123")!
        print("Connecting to WebSocket at '\(url)'...")
        let connection = try WebsocketConnection(url: url)

        var shouldClose = false

        for try await event in connection.receive() {
            switch event {
            case .string(let message):
                print("Received string message: \(message)")

                if message == "Order 123 status update: Completed" {
                    print("Received completion message, closing connection.")
                    shouldClose = true
                    break
                }

            case .data(let data):
                print("Received data message: \(data)")

            @unknown default:
                print("Received unknown message")
            }

            if shouldClose {
                break
            }
        }

        // Verbindung explizit schließen, damit der Stream sicher beendet wird,
        // falls der Server keinen Close-Frame sendet.
        connection.close()

        XCTAssertTrue(shouldClose)
        print("Test completed.")
    }
}
