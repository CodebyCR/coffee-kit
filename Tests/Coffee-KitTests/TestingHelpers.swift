
import Foundation
import Testing

/// Returns true if API-dependent tests should be run.
/// This is controlled by the environment variable `RUN_API_TESTS=1`.
public var shouldRunAPITests: Bool {
    ProcessInfo.processInfo.environment["RUN_API_TESTS"] == "1"
}

public extension Trait where Self == ConditionTrait {
    /// Runs the test only when API-dependent tests are enabled.
    static var requiresAPI: Self {
        .enabled(if: shouldRunAPITests, "Skipping API-dependent test. Set RUN_API_TESTS=1 to enable.")
    }
}
