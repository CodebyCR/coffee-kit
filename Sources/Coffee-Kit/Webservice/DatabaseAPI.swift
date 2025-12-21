//
//  APISystem.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation

public struct DatabaseAPI {
    public let baseURL: URL
    public let socketURL: URL
    private static let localHostname = "cr-mac.local"

    public static var dev: DatabaseAPI {
        let baseURL = URL(string: "http://\(localHostname):8080/test")!
        let socketURL = URL(string: "ws://\(localHostname):8080/test")!

        return DatabaseAPI(baseURL: baseURL, socketURL: socketURL)
    }

    public static var productiv: DatabaseAPI {
        let baseURL = URL(string: "http://\(localHostname):8080/prod")!
        let socketURL = URL(string: "ws://\(localHostname):8080/prod")!

        return DatabaseAPI(baseURL: baseURL, socketURL: socketURL)
    }
}
