//
//  URLExtension.swift
//  Swift-Extensions
//
//  Created by Christoph Rohde on 07.01.25.
//


import Foundation

public extension URL {

    /// Append path to URL with /
    /// - Parameters:
    ///  urlComponent: path
    ///  - Returns: URL
    ///  - Complexity: O(1)
    ///  - Example:
    ///  ```
    ///  let baseURL = URL(string: "http://myserver.com")!
    ///  let subAPI = "weather"
    ///  let version = "v1"
    ///
    ///  let url = baseURL / subAPI / version
    ///  ```
    ///  - Note: The result is http://myserver.com/weather/v1
    ///
    ///  - Important: The path must not contain a leading or trailing /
    ///
    /// - Precondition: The URL must be valid
    /// - Postcondition: The URL is appended with the path

    static func / (lhs: consuming URL, rhs: consuming String) -> URL {
        return lhs.appendingPathComponent(rhs)
    }

}
