//
//  AsyncSequence.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 15.05.25.
//

import Foundation

// MARK: - AsyncSequence



nonisolated public extension AsyncSequence {
    /// - Note: Marked `@concurrent` because the package deployment target
    ///   (macOS 14 / iOS 17) predates `AsyncIteratorProtocol.next(isolation:)`,
    ///   so iteration always hops off the caller's actor. This means the sequence's
    ///   conformances must not be actor-isolated.
    @concurrent
    func collect<C: RangeReplaceableCollection>(
        into initialValue: C = C()
    ) async throws -> C where C.Element == Element {
        var result = initialValue
        for try await element in self {
            result.append(element)
        }
        return result
    }
}
