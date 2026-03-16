//
//  AsyncMeasure.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 06.07.25.
//

import Foundation

// MARK: - Performance Result Types

struct PerformanceResult<T> {
    let results: [T]
    let durations: [Duration]
    let average: Duration
    let min: Duration
    let max: Duration
    let standardDeviation: Duration
    let iterations: Int

    var averageInSeconds: Double {
        return Double(average.components.seconds) + Double(average.components.attoseconds) / 1_000_000_000_000_000_000
    }

    var averageInMilliseconds: Double {
        return averageInSeconds * 1000
    }

    var averageInMicroseconds: Double {
        return averageInSeconds * 1_000_000
    }

    func summary() -> String {
        return """
        Performance Summary:
        - Iterations: \(iterations)
        - Average: \(String(format: "%.3f", averageInMilliseconds))ms
        - Min: \(String(format: "%.3f", minInMilliseconds))ms
        - Max: \(String(format: "%.3f", maxInMilliseconds))ms
        - Standard Deviation: \(String(format: "%.3f", standardDeviationInMilliseconds))ms
        """
    }

    private var minInMilliseconds: Double {
        let minSeconds = Double(min.components.seconds) + Double(min.components.attoseconds) / 1_000_000_000_000_000_000
        return minSeconds * 1000
    }

    private var maxInMilliseconds: Double {
        let maxSeconds = Double(max.components.seconds) + Double(max.components.attoseconds) / 1_000_000_000_000_000_000
        return maxSeconds * 1000
    }

    private var standardDeviationInMilliseconds: Double {
        let stdDevSeconds = Double(standardDeviation.components.seconds) + Double(standardDeviation.components.attoseconds) / 1_000_000_000_000_000_000
        return stdDevSeconds * 1000
    }
}

struct VoidPerformanceResult {
    let durations: [Duration]
    let average: Duration
    let min: Duration
    let max: Duration
    let standardDeviation: Duration
    let iterations: Int

    var averageInSeconds: Double {
        return Double(average.components.seconds) + Double(average.components.attoseconds) / 1_000_000_000_000_000_000
    }

    var averageInMilliseconds: Double {
        return averageInSeconds * 1000
    }

    var averageInMicroseconds: Double {
        return averageInSeconds * 1_000_000
    }

    func summary() -> String {
        return """
        Performance Summary:
        - Iterations: \(iterations)
        - Average: \(String(format: "%.3f", averageInMilliseconds))ms
        - Min: \(String(format: "%.3f", minInMilliseconds))ms
        - Max: \(String(format: "%.3f", maxInMilliseconds))ms
        - Standard Deviation: \(String(format: "%.3f", standardDeviationInMilliseconds))ms
        """
    }

    private var minInMilliseconds: Double {
        let minSeconds = Double(min.components.seconds) + Double(min.components.attoseconds) / 1_000_000_000_000_000_000
        return minSeconds * 1000
    }

    private var maxInMilliseconds: Double {
        let maxSeconds = Double(max.components.seconds) + Double(max.components.attoseconds) / 1_000_000_000_000_000_000
        return maxSeconds * 1000
    }

    private var standardDeviationInMilliseconds: Double {
        let stdDevSeconds = Double(standardDeviation.components.seconds) + Double(standardDeviation.components.attoseconds) / 1_000_000_000_000_000_000
        return stdDevSeconds * 1000
    }
}

// MARK: - Async Performance Measurement Extensions

extension Task where Success == Never, Failure == Never {

    /// Measures the performance of an async operation that returns a value
    /// - Parameters:
    ///   - iterations: Number of times to run the operation (default: 10)
    ///   - warmupIterations: Number of warmup runs before measurement (default: 1)
    ///   - operation: The async operation to measure
    /// - Returns: PerformanceResult containing timing statistics and results
    static func measureAsync<T>(
        iterations: Int = 10,
        warmupIterations: Int = 1,
        operation: @escaping () async throws -> T
    ) async rethrows -> PerformanceResult<T> {

        precondition(iterations > 0, "Iterations must be greater than 0")
        precondition(warmupIterations >= 0, "Warmup iterations must be non-negative")

        let clock = ContinuousClock()

        // Warmup phase
        for _ in 0..<warmupIterations {
            _ = try await operation()
        }

        var results: [T] = []
        var durations: [Duration] = []

        // Measurement phase
        for _ in 0..<iterations {
            let start = clock.now
            let result = try await operation()
            let duration = clock.now - start

            results.append(result)
            durations.append(duration)
        }

        return PerformanceResult(
            results: results,
            durations: durations,
            average: calculateAverage(durations),
            min: durations.min()!,
            max: durations.max()!,
            standardDeviation: calculateStandardDeviation(durations),
            iterations: iterations
        )
    }

    /// Measures the performance of an async operation that doesn't return a value
    /// - Parameters:
    ///   - iterations: Number of times to run the operation (default: 10)
    ///   - warmupIterations: Number of warmup runs before measurement (default: 1)
    ///   - operation: The async operation to measure
    /// - Returns: VoidPerformanceResult containing timing statistics
    static func measureAsync(
        iterations: Int = 10,
        warmupIterations: Int = 1,
        operation: @escaping () async throws -> Void
    ) async rethrows -> VoidPerformanceResult {

        precondition(iterations > 0, "Iterations must be greater than 0")
        precondition(warmupIterations >= 0, "Warmup iterations must be non-negative")

        let clock = ContinuousClock()

        // Warmup phase
        for _ in 0..<warmupIterations {
            try await operation()
        }

        var durations: [Duration] = []

        // Measurement phase
        for _ in 0..<iterations {
            let start = clock.now
            try await operation()
            let duration = clock.now - start

            durations.append(duration)
        }

        return VoidPerformanceResult(
            durations: durations,
            average: calculateAverage(durations),
            min: durations.min()!,
            max: durations.max()!,
            standardDeviation: calculateStandardDeviation(durations),
            iterations: iterations
        )
    }

    /// Measures the performance of multiple concurrent async operations
    /// - Parameters:
    ///   - concurrency: Number of concurrent operations to run
    ///   - iterations: Number of times to run the concurrent batch (default: 10)
    ///   - warmupIterations: Number of warmup runs before measurement (default: 1)
    ///   - operation: The async operation to measure
    /// - Returns: VoidPerformanceResult containing timing statistics for the entire batch
    static func measureAsyncConcurrent<T>(
        concurrency: Int,
        iterations: Int = 10,
        warmupIterations: Int = 1,
        operation: @escaping () async throws -> T
    ) async rethrows -> VoidPerformanceResult {

        precondition(concurrency > 0, "Concurrency must be greater than 0")
        precondition(iterations > 0, "Iterations must be greater than 0")
        precondition(warmupIterations >= 0, "Warmup iterations must be non-negative")

        let clock = ContinuousClock()

        // Warmup phase
        for _ in 0..<warmupIterations {
            try await withThrowingTaskGroup(of: T.self) { group in
                for _ in 0..<concurrency {
                    group.addTask {
                        return try await operation()
                    }
                }

                for try await _ in group {
                    // Consume results
                }
            }
        }

        var durations: [Duration] = []

        // Measurement phase
        for _ in 0..<iterations {
            let start = clock.now

            try await withThrowingTaskGroup(of: T.self) { group in
                for _ in 0..<concurrency {
                    group.addTask {
                        return try await operation()
                    }
                }

                for try await _ in group {
                    // Consume results
                }
            }

            let duration = clock.now - start
            durations.append(duration)
        }

        return VoidPerformanceResult(
            durations: durations,
            average: calculateAverage(durations),
            min: durations.min()!,
            max: durations.max()!,
            standardDeviation: calculateStandardDeviation(durations),
            iterations: iterations
        )
    }
}

// MARK: - Private Helper Functions

private func calculateAverage(_ durations: [Duration]) -> Duration {
    let totalNanoseconds = durations.reduce(0) { sum, duration in
        return sum + duration.components.seconds * 1_000_000_000 + duration.components.attoseconds / 1_000_000_000
    }
    let averageNanoseconds = totalNanoseconds / Int64(durations.count)
    return Duration(secondsComponent: averageNanoseconds / 1_000_000_000,
                   attosecondsComponent: (averageNanoseconds % 1_000_000_000) * 1_000_000_000)
}

private func calculateStandardDeviation(_ durations: [Duration]) -> Duration {
    let average = calculateAverage(durations)
    let averageNanoseconds = average.components.seconds * 1_000_000_000 + average.components.attoseconds / 1_000_000_000

    let variance = durations.reduce(0) { sum, duration in
        let durationNanoseconds = duration.components.seconds * 1_000_000_000 + duration.components.attoseconds / 1_000_000_000
        let diff = durationNanoseconds - averageNanoseconds
        return sum + (diff * diff)
    } / Int64(durations.count)

    let stdDevNanoseconds = Int64(sqrt(Double(variance)))
    return Duration(secondsComponent: stdDevNanoseconds / 1_000_000_000,
                   attosecondsComponent: (stdDevNanoseconds % 1_000_000_000) * 1_000_000_000)
}

// MARK: - Usage Examples

/*
// Example 1: Basic async function measurement
let result = await Task.measureAsync(iterations: 20) {
    await someAsyncOperation()
}
print(result.summary())
print("Average time: \(result.averageInMilliseconds)ms")

// Example 2: Void async function measurement
let voidResult = await Task.measureAsync(iterations: 10, warmupIterations: 2) {
    await performSomeAsyncTask()
}
print(voidResult.summary())

// Example 3: Concurrent operations measurement
let concurrentResult = await Task.measureAsyncConcurrent(
    concurrency: 5,
    iterations: 10
) {
    await expensiveAsyncOperation()
}
print("Concurrent execution time: \(concurrentResult.averageInMilliseconds)ms")

// Example 4: Accessing individual results
let detailedResult = await Task.measureAsync {
    return await fetchDataFromAPI()
}
for (index, result) in detailedResult.results.enumerated() {
    print("Result \(index): \(result)")
}
*/
