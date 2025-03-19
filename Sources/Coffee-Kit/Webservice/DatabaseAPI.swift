//
//  APISystem.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 20.10.24.
//

import Foundation

public struct DatabaseAPI {
    public let baseURL: URL

    public static var dev: DatabaseAPI {
        return DatabaseAPI(baseURL: URL(fileURLWithPath: "http://127.0.0.1:8080/test"))
    }

    public static var productiv: DatabaseAPI {
        return DatabaseAPI(baseURL: URL(fileURLWithPath: "http://127.0.0.1:8080/prod"))
    }
}
