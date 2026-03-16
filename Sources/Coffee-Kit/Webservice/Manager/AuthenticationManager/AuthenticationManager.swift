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
    case invalidEmailFormat
    case passwordsDontMatch

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
        case .invalidEmailFormat:
            String(localized: "The given email is not valid.")
        case .passwordsDontMatch:
            String(localized: "The given passwords do not match.")
        }
    }
}

public enum CredentialState {
    case valid(String)
    case invalid(CreadentialDenyReason)
}

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case userAlreadyExists
    case serverError(String)
    case decodingError
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Ungültige E-Mail oder Passwort."
        case .userAlreadyExists: return "Ein Benutzer mit dieser E-Mail existiert bereits."
        case .serverError(let message): return message
        case .decodingError: return "Fehler beim Verarbeiten der Server-Antwort."
        case .invalidURL: return "Ungültige Server-URL."
        }
    }
}

@Observable
public final class AuthenticationManger {
    public var name: String = ""
    public var email: String = ""
    public var password: String = ""
    public var passwordRetyped: String = ""
    

    public var isValidEmail: CredentialState {
        guard !email.contains(" ") else {
            return .invalid(.invalidEmailFormat)
        }

        let parts = email.split(separator: "@")
        guard parts.count == 2 else {
            return .invalid(.invalidEmailFormat)
        }

        let localPart = parts[0]
        let domainPart = parts[1]

        guard !localPart.isEmpty else {
            return .invalid(.invalidEmailFormat)
        }

        let domainParts = domainPart.split(separator: ".")
        guard domainParts.count >= 2 else {
            return .invalid(.invalidEmailFormat)
        }

        guard !domainParts.first!.isEmpty,
              !domainParts.last!.isEmpty else {
            return .invalid(.invalidEmailFormat)
        }
        
        return .valid(email)
    }

    public var isValiPassword: CredentialState {
        guard password.count >= 8 else {
            return .invalid(.lessThenEightSimboles)
        }
        
        guard password.contains(where: { $0.isUppercase }) else {
            return .invalid(.noUppercaseLetter)
        }
        
        guard password.contains(where: { $0.isLowercase }) else {
            return .invalid(.noLowercaseLetter)
        }
        
        guard password.contains(where: { $0.isNumber }) else {
            return .invalid(.noNumbersIncluded)
        }
        
        guard password.contains(where: { "!@#$%^&*(),.?".contains($0) }) else {
            return .invalid(.noSpecialCharacter)
        }
        
        guard password == passwordRetyped else {
            return .invalid(.passwordsDontMatch)
        }
        
        return .valid(password)
    }
    
    private let baseURL = "http://127.0.0.1:8080/test/authentication"
//
//        func login(email: String, password: String) async throws -> User {
//            guard let url = URL(string: "\(baseURL)/login") else { throw AuthError.invalidURL }
//            
//            let body = ["email": email, "password": password]
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//            
//            let (data, response) = try await URLSession.shared.data(for: request)
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw AuthError.serverError("Keine Antwort vom Server")
//            }
//            
//            if httpResponse.statusCode == 200 {
//                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
//                // Da die API beim Login nur das Token zurückgibt, erstellen wir ein User-Objekt mit den bekannten Daten
//                return User(email: email, name: "Benutzer", token: loginResponse.token)
//            } else {
//                throw AuthError.invalidCredentials
//            }
//        }

//        func register(email: String, password: String, name: String) async throws -> User {
//            guard let url = URL(string: "\(baseURL)/register") else { throw AuthError.invalidURL }
//            
//            let body = ["name": name, "email": email, "password": password]
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.httpBody = try JSONSerialization.data(withJSONObject: body)
//            
//            let (data, response) = try await URLSession.shared.data(for: request)
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                throw AuthError.serverError("Keine Antwort vom Server")
//            }
//            
//            if httpResponse.statusCode == 200 {
//                // Nach erfolgreicher Registrierung loggen wir den User direkt ein
//                let user = try await login(email: email, password: password)
//                
//                
//                return User(email: user.email, name: name, token: user.token)
//            } else {
//                let message = String(data: data, encoding: .utf8) ?? "Registrierung fehlgeschlagen"
//                throw AuthError.serverError(message)
//            }
//        }
}
