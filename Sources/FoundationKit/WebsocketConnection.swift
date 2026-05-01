
//  Coffee-Kit
//
//  Created by Christoph Rohde on 25.10.25.
//

import Foundation

public enum WebSocketConnectionError: Error {
    case connectionError
    case transportError
    case encodingError
    case decodingError
    case disconnected
    case closed
}

public struct WebsocketConnection: Sendable {
    private let webSocketTask: URLSessionWebSocketTask

    public init(url: URL) throws {
        guard url.scheme == "ws" || url.scheme == "wss" else {
            throw URLError(.badURL)
        }

        // You may want a custom URLSession if you need timeouts, headers, etc.
        self.webSocketTask = URLSession.shared.webSocketTask(with: url)

        // Start the task so receive/send can work
        self.webSocketTask.resume()
    }

    private func mapCloseCodeToError(_ code: URLSessionWebSocketTask.CloseCode) -> WebSocketConnectionError {
        switch code {
        case .normalClosure:
            return .closed
        case .goingAway:
            return .disconnected
        case .invalid:
            return .connectionError
        default:
            return .transportError
        }
    }

    private func receiveSingleMessage() async throws -> URLSessionWebSocketTask.Message {
        try await webSocketTask.receive()
    }

    // Reads a single message and maps transport/close situations
    func receiveOnce() async throws -> URLSessionWebSocketTask.Message {
        do {
            return try await receiveSingleMessage()
        } catch {
            // If the task has a meaningful close code, prefer mapping it
            let code = webSocketTask.closeCode
            if code != .invalid {
                throw mapCloseCodeToError(code)
            }
            // Otherwise, bubble up as a transport error
            throw WebSocketConnectionError.transportError
        }
    }

    // Continuous stream of messages; finishes on close or error; respects cancellation
    public func receive() -> AsyncThrowingStream<URLSessionWebSocketTask.Message, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                while !Task.isCancelled {
                    do {
                        let message = try await receiveOnce()
                        if Task.isCancelled {
                            break
                        }
                        continuation.yield(message)
                    } catch let error as WebSocketConnectionError {
                        // Finish gracefully on known close/connection states
                        switch error {
                        case .closed, .disconnected:
                            continuation.finish()
                        default:
                            continuation.finish(throwing: error)
                        }
                        return
                    } catch {
                        continuation.finish(throwing: error)
                        return
                    }
                }
                continuation.finish()
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    func close() {
        webSocketTask.cancel(with: .normalClosure, reason: nil)
    }
}
