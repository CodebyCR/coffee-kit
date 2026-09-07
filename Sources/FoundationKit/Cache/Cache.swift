//
//  Cache.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 16.05.25.
//

import Foundation
import OSLog

/// A thread-safe cache managed by an actor to ensure isolation through Structured Concurrency.
public actor Cache<Key: Hashable & Sendable & CustomDebugStringConvertible, Value: Sendable & CustomDebugStringConvertible> {
    private let log = Logger(subsystem: "Coffee-Kit", category: "Cache")
    
    // MARK: - Properties

    /// The maximum size of the cache in bytes.
    private let memoryLimit: Int

    /// The current size of the cache in bytes.
    public private(set) var memoryUsage: Int

    /// The internal storage.
    private var cache: [Key: Value]

    // MARK: - Initializer

    public init(memoryLimitInMB: Int = 50) {
        precondition(memoryLimitInMB >= 0, "memoryLimit cannot be negative.")
        self.memoryLimit = memoryLimitInMB * 1024 * 1024
        self.cache = [:]
        self.memoryUsage = 0
    }

    // MARK: - Computed Properties

    public var count: Int {
        cache.count
    }

    // MARK: - Static Factory

    /// Creates a Cache instance and populates it concurrently using a TaskGroup.
    @Sendable public static func create(
        by keyList: [Key],
        limitedTo memoryLimit: Int = 50,
        with fetcher: @Sendable @escaping (Key) async throws -> Value
    ) async throws -> Cache<Key, Value> {
        let cache = Cache<Key, Value>(memoryLimitInMB: memoryLimit)

        // Structured Concurrency: Using TaskGroup for concurrent fetching
        try await withThrowingTaskGroup(of: (Key, Value).self) { group in
            for key in keyList {
                group.addTask {
                    let value = try await fetcher(key)
                    return (key, value)
                }
            }

            for try await (key, value) in group {
                await cache.set(key: key, value: value)
            }
        }

        return cache
    }

    // MARK: - Methods

    /// Fills the cache with multiple items concurrently using a TaskGroup.
    public func fillUp(
        by keyList: [Key],
        with fetcher: @Sendable @escaping (Key) async throws -> Value
    ) async throws {
        try await withThrowingTaskGroup(of: (Key, Value).self) { group in
            for key in keyList {
                group.addTask {
                    let value = try await fetcher(key)
                    return (key, value)
                }
            }

            for try await (key, value) in group {
                self.set(key: key, value: value)
            }
        }
    }

    public func fetch(key: Key, with fetcher: @escaping (Key) async throws -> Value) async throws -> Value {
        if let value = cache[key] {
            return value
        }

        let value = try await fetcher(key)
        self.set(key: key, value: value)
        return value
    }

    public func set(key: Key, value: Value) {
        if let oldValue = cache[key] {
            memoryUsage -= MemoryLayout.size(ofValue: oldValue)
        }

        let valueSize = MemoryLayout.size(ofValue: value)
        if (memoryUsage + valueSize) > memoryLimit {
            return
        }

        memoryUsage += valueSize
        cache[key] = value
    }

    public func remove(key: Key) {
        guard let value = cache[key] else { return }
        memoryUsage -= MemoryLayout.size(ofValue: value)
        cache.removeValue(forKey: key)
    }

    public func get(key: Key) -> Value? {
        cache[key]
    }

    public func clear() {
        cache.removeAll()
        memoryUsage = 0
    }

    public func contains(key: Key) -> Bool {
        cache[key] != nil
    }

    public func values() -> [Value] {
        Array(cache.values)
    }

    // MARK: - Subscript

    public subscript(key: Key) -> Value? {
        get {
            cache[key]
        }
        set {
            if let newValue = newValue {
                self.set(key: key, value: newValue)
            } else {
                self.remove(key: key)
            }
        }
    }
}
