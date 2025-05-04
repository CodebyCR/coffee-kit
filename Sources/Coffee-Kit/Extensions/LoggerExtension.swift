//
//  OSLogExtension.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 18.04.25.
//
import Foundation
import OSLog

public extension Logger {
    func trackTask(called name: String, task: () async throws -> Void) async {
        let startTime = Date()
        let duration: TimeInterval


        do {
            try await task()
            duration = Date().timeIntervalSince(startTime)

            // split duration into minutes, seconds and milliseconds
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            let milliseconds = Int((duration - Double(minutes * 60 + seconds)) * 1000)

            self.info("Task '\(name)' successful completed in \(minutes) minutes, \(seconds) seconds and \(milliseconds) milliseconds")
        } catch {
            duration = Date().timeIntervalSince(startTime)

            // split duration into minutes, seconds and milliseconds
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            let milliseconds = Int((duration - Double(minutes * 60 + seconds)) * 1000)
            self.error("Task '\(name)' failed in \(minutes) minutes, \(seconds) seconds and \(milliseconds) milliseconds")
            self.error("Error: \(error.localizedDescription)")
        }
    }
}
