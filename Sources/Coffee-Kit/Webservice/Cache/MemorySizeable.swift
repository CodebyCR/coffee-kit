//
//  MemorySizeable.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 17.05.25.
//

import Foundation

/// A protocol that defines a size in bytes.
public protocol MemorySizable {
    var estimatedMemorySize: Int { get }
}
