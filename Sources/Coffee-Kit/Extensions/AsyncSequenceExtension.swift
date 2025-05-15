//
//  AsyncSequence.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 15.05.25.
//

import Foundation

// MARK: - AsyncSequence



extension AsyncSequence {
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
