//
//  LoginError.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 13.07.25.
//

import Foundation

public enum LoginError: LocalizedError {
    case weakPassword
    case invalidCredentials
    case serverError(String)
    case noInternetConnection
    case invalidSession
}

extension LoginError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .weakPassword:
            return "The password provided is too weak."
        case .invalidCredentials:
            return "Invalid credentials provided."
        case .serverError(let message):
            return "Server error: \(message)"
        case .noInternetConnection:
            return "No internet connection available."
        case .invalidSession:
            return "The session is invalid or has expired."

        }
    }
}

extension LoginError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
            case .weakPassword:
            return "LoginError.weakPassword"
        case .invalidCredentials:
            return "LoginError.invalidCredentials"
        case .serverError(let message):
            return "LoginError.serverError(\(message))"
        case .noInternetConnection:
            return "LoginError.noInternetConnection"
        case .invalidSession:
            return "LoginError.invalidSession"
        }
    }
}

extension LoginError: Sendable {}
