//
//  MemorySizeableExtension.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 17.05.25.
//

import Foundation

// MARK: - Primitive Types

extension Int: MemorySizable {
    public var estimatedMemorySize: Int { MemoryLayout<Int>.size }
}

extension Double: MemorySizable {
    public var estimatedMemorySize: Int { MemoryLayout<Double>.size }
}

extension Bool: MemorySizable {
    public var estimatedMemorySize: Int { MemoryLayout<Bool>.size }
}

extension String: MemorySizable {
    public var estimatedMemorySize: Int {
        return 16 + self.utf8.count
    }
}

// MARK: - Collection Types

extension Array: MemorySizable where Element: MemorySizable {
    public var estimatedMemorySize: Int {
        return 8 + self.reduce(0) { $0 + $1.estimatedMemorySize }
    }
}


extension Optional: MemorySizable where Wrapped: MemorySizable {
    public var estimatedMemorySize: Int {
        switch self {
        case .none:
            return 1
        case .some(let value):
            return value.estimatedMemorySize + 1
        }
    }
}
