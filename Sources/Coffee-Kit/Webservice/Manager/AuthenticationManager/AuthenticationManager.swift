//
//  AuthenticationManager.swift
//  Coffee-Kit
//
//  Created by Christoph Rohde on 14.03.26.
//
import Foundation


public enum CreadentialDenyReason {
    case noNumbersIncluded
    case noSpecialCharacter
    case noUppercaseLetter
    case noLowercaseLetter
    case lessThenEightSimboles

    public var message: String {
        return switch self {
        case .noLowercaseLetter:
            String(localized: "No lower case letter included.")
        case .lessThenEightSimboles:
            String(localized: "The given password is to short, please use at least 8 symbols.")
        case .noNumbersIncluded:
            String(localized: "No number included.")
        case .noUppercaseLetter:
            String(localized: "No upper case letter included.")
        case .noSpecialCharacter:
            String(localized: "No special case letter included.")
        }
    }
}

public enum CredentialState {
    case valid(String)
    case invalid(CreadentialDenyReason)
}


@Observable
public final class AuthenticationManger {
    public var name: String = ""
    public var email: String = ""
    public var password: String = ""
    public var passwordRetyped: String = ""
    

    public var isValidEmail: CredentialState {
        .valid("placeholder")
    }

    public var isValiPassword: CredentialState {
        .valid("placeholder")
    }
}
