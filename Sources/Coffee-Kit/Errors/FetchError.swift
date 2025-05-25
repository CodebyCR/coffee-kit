//
//  FetchError.swift
//  Coffee Lover
//
//  Created by Christoph Rohde on 27.11.24.
//

public enum FetchError: Error {
    case decodingError
    case invalidResponse
    case invalidSelfReference
}
