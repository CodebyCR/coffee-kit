//
//  File.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 16.05.25.
//

import Foundation

public actor Cache<Key: Hashable & Sendable, Value: Sendable> {
    // MARK: - Properties

    /// The  size of the cache in bytes.
    /// The default is 50 MB.
    private let memoryLimit: Int

    /// The current size of the cache in bytes.
    private(set) var memoryUsage: Int

    /// The cache dictionary.
    private(set) var cache: [Key: Value]

    // MARK: - Initializer

    public init() {
        memoryLimit = 50 * 1024 * 1024 // 50 MB
        cache = [:]
        memoryUsage = MemoryLayout.size(ofValue: cache)
    }

    public init(memoryLimit: Int) {
        precondition(memoryLimit >= 0, "memoryLimit cannot be negative.")
        self.memoryLimit = memoryLimit
        cache = [:]
        memoryUsage = MemoryLayout.size(ofValue: cache)
    }

    // MARK: - Computed Properties

    public var count: Int {
        cache.count
    }

    // MARK: - Static

    /// This method creates a Cache instance and populates it with values fetched from the provided fetcher closure.
    /// It uses a task group to fetch the values concurrently.
    /// - Parameters:
    ///   - keyList: An array of keys to fetch values for.
    ///   - memoryLimit: The maximum memory limit for the cache. Default is 50 MB.
    ///   - fetcher: An asynchronous closure that takes a key and returns a value.
    ///   - Returns: A Cache instance populated with the fetched values.
    ///   - Throws: An error if the fetching process fails.
    @Sendable public static func create(
        by keyList: [Key],
        limitedTo memoryLimit: Int = 50 * 1024 * 1024,
        with fetcher: @Sendable @escaping (Key) async throws -> Value
    ) async throws -> Cache<Key, Value> {
        let cache = Cache<Key, Value>(memoryLimit: memoryLimit)

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

    @Sendable public func fillUp(
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

//    @Sendable public func fillUp(
//        by keyList: [Key],
//        use fetcher: MenuFetchAction<Key, Value>
//    ) async throws {
//
//        try await withThrowingTaskGroup(of: (Key, Value).self) { group in
//            for key in keyList {
//                group.addTask {
//                    let value = try await fetcher(key)
//                    return (key, value)
//                }
//            }
//
//            for try await (key, value) in group {
//                self.set(key: key, value: value)
//            }
//        }
//
//    }

    // MARK: - Methods

    // init with id list, welche fetched mit TaskGroup

    public func fetch(key: Key, with fetcher: @escaping (Key) async throws -> Value) async throws -> Value {
        if let value = cache[key] {
            return value
        }

        let value = try await fetcher(key)

        if !maxCacheSizeReached(with: MemoryLayout.size(ofValue: value)) {
            self[key] = value
        }

        return value
    }

    private func add(key: Key, value: Value) {
        self[key] = value
    }

    public func set(key: Key, value: Value) {
        if let oldValue = cache[key] {
            memoryUsage -= MemoryLayout.size(ofValue: oldValue)
        }

        if maxCacheSizeReached(with: MemoryLayout.size(ofValue: value)) {
            print("Cache size limit reached. Cannot add new value.")
            return
        }

        memoryUsage += MemoryLayout.size(ofValue: value)
        cache[key] = value
    }

    public func remove(key: Key) {
        guard let value = cache[key]
        else {
            return
        }
        memoryUsage -= MemoryLayout.size(ofValue: value)
        cache.removeValue(forKey: key)
    }

    public func get(key: Key) -> Value? {
        self[key]
    }

    public func clear() {
        cache.removeAll()
        memoryUsage = MemoryLayout.size(ofValue: cache)
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
                memoryUsage += MemoryLayout.size(ofValue: newValue)
                cache[key] = newValue
            } else {
                cache.removeValue(forKey: key)
            }
        }
    }

    // MARK: - Memory Management

    private func maxCacheSizeReached(with valueSize: Int) -> Bool {
        let newMemoryUsage = memoryUsage + valueSize
        print("New memory usage: \(newMemoryUsage) bytes")
        return newMemoryUsage > memoryLimit
    }
}
