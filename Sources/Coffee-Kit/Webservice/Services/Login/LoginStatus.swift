//
//  LoginStatus.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 13.07.25.
//

import Foundation

@frozen
public enum LoginStatus {
    case idle
    case loading
    case loggedIn(User)
    case error(LoginError)
    case loggedOut
}

// MARK: - Sendable
extension LoginStatus: Sendable {}

// MARK: - CustomStringConvertible
extension LoginStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .idle:
            return "Idle"
        case .loading:
            return "Loading"
        case .loggedIn(let user):
            return "Logged in as \(user.name)"
        case .error(let error):
            return "Error: \(error.localizedDescription)"
        case .loggedOut:
            return "Logged out"
        }
    }
}

// MARK: - Equatable
extension LoginStatus: Equatable {
    public static func == (lhs: LoginStatus, rhs: LoginStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.loggedOut, .loggedOut):
            return true
        case (.loggedIn(let user1), .loggedIn(let user2)):
            return user1.id == user2.id
        case (.error(let error1), .error(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
}

// MARK: - Hashable
extension LoginStatus: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .idle:
            hasher.combine(0)
        case .loading:
            hasher.combine(1)
        case .loggedIn(let user):
            hasher.combine(2)
            hasher.combine(user.id)
        case .error(let error):
            hasher.combine(3)
            hasher.combine(error.localizedDescription)
        case .loggedOut:
            hasher.combine(4)
        }
    }
}






