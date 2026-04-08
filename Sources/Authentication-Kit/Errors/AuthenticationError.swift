//
//  AuthenticationError.swift
//  AuhenticationTest
//
//  Created by Christoph Rohde on 21.03.26.
//
import Foundation

public enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case serverError(String)
    case decodingError
    case invalidURL
    
    case notLoggedIn
    case sessionExpired
    case keychainError(KeychainError)
    case networkError(URLError)
    case invalidResponse
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password."
        case .userAlreadyExists: return "A user with this email already exists."
        case .serverError(let message): return message
        case .decodingError: return "Error processing server response."
        case .invalidURL: return "Invalid server URL."
        case .notLoggedIn: return "You are not logged in."
        case .sessionExpired: return "Your session has expired. Please log in again."
        case .keychainError(let error): return error.localizedDescription
        case .networkError(let error): return error.localizedDescription
        case .invalidResponse: return "Invalid response from server."
        }
    }
}
